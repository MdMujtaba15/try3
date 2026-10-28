# Material Damage py


from typing import List
import catboost as cb
from colorama import Fore
from datetime import datetime, timedelta
from lob.base import BaseLOB
import numpy as np
import os
import pandas as pd
import shap
from sklearn.model_selection import train_test_split
from utils import calculate_time, convert_path_to_lib, save_sas_log, handle_error


class MaterialDamage(BaseLOB):

    def get_lob_name(self):
        return "Material Damage"

    def get_script_names(self) -> List[str]:
        return [
            "1 Combine Hours and Counts Data.sas",
            "2 Adjuster Addresses v2.sas",
            "3 New MDA Data Pull v2.sas",
            "4 Scoring File PSI.sas",
            "6 Import and Prep Python Output v2 Superfile Fixes.sas",
        ]

    def get_output_file_names(self) -> List[str]:
        return [
            "QlikAdjustments SAS_md.xlsx",
            "QlikSuperfile_md.xlsx",
        ]

    def initialize_variables_for_sas(self):
        if self.path_type == "local":
            self.mdl_curr = self.lib_path
            self.mdl_prir = self.lib_path
            self.saveLoc = self.lib_path
        else:
            self.mdl_curr = convert_path_to_lib(self.lib_path)
            prior_dt_path = os.path.abspath(
                os.path.join(
                    self.grand_dir,
                    self.get_lob_name(),
                    f"{self.year_prior}",
                    self.folder_dt_prior,
                )
            )
            self.mdl_prir = convert_path_to_lib(prior_dt_path)
            self.saveLoc = self.lob_output_dir
        self.src = convert_path_to_lib(
            os.path.join(os.path.split(self.sas_scripts_path)[0], "Source")
        )
        self.logger.log(f"self.src: {self.src}")

    @calculate_time
    @handle_error
    def step_1(self):
        """
        lob: Material Damage
        script: 1 Combine Hours and Counts Data.sas
        """
        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "1 Combine Hours and Counts Data.sas")
        ) as file:
            code = file.read()

        # calculating the value of cut off and end ppd date that are to be used inside the SAS script
        cutoff = datetime.strptime(self.last_folder, "%m-%d-%Y") - timedelta(
            days=(3 * 365) + (7 * 30)
        )
        cutoff = cutoff.replace(day=1)
        self.cutoff = cutoff.strftime("%m-%d-%Y")

        params = {
            "endppd": self.last_folder,
            "cutoff": self.cutoff,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS1.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["adj_decode.sas7bdat", "hcoutput.sas7bdat"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 1 executed successfully")
            self.logger.log(
                "Output: adj_decode.sas7bdat and hcoutput.sas7bdat", color=Fore.YELLOW
            )

    @calculate_time
    @handle_error
    def step_2(self):
        """
        lob: Material Damage
        script: 2 Adjuster Addresses v2.sas
        """
        # creating library, that is to be used internally in the SAS script to be executed
        self.sas_client.saslib("src", path=self.src)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "2 Adjuster Addresses v2.sas")
        ) as file:
            code = file.read()

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS2.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        self.logger.log("SAS script 2 executed successfully")
        self.logger.log("Output: No Physical file", color=Fore.YELLOW)

    @calculate_time
    @handle_error
    def step_3(self):
        """
        lob: Material Damage
        script: 3 New MDA Data Pull v2.sas
        """
        # Adjusting the format of date as per the requirement of the program

        frm_dt = datetime.strptime(self.cutoff, "%m-%d-%Y")
        frm_dt = frm_dt.strftime("%d%B%Y").upper()
        frm_dt = f"{frm_dt}:00:00:00"

        to_dt = datetime.strptime(self.last_folder, "%m-%d-%Y")
        to_dt = to_dt.strftime("%d%B%Y").upper()
        to_dt = f"{to_dt}:23:59:59"

        frm_dt = f"'{frm_dt}'"
        to_dt = f"'{to_dt}'"

        # creating library, that is to be used internally in the SAS script to be executed
        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)
        self.sas_client.saslib("src", path=self.src)
        # fetch code from the SAS Script
        with open(
            os.path.join(
                self.sas_scripts_path,
                "3 New MDA Data Pull v2.sas",
            )
        ) as file:
            code = file.read()

        # passing the values of variables, to be used inside the SAS script
        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")
        params = {
            "last_folder": self.last_folder,
            "year": folder_date.year,
            "from_dt": frm_dt,
            "to_dt": to_dt,
            "flag": self.flag,
            "output_path_csv": self.mdl_curr,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS3.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["CBscoringv2.csv", "for_pythonscoring.sas7bdat"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 3 executed successfully")
            self.logger.log(
                "Output: CBscoringv2.csv and for_pythonscoring.sas7bdat",
                color=Fore.YELLOW,
            )

    @calculate_time
    @handle_error
    def step_4(self):
        """
        lob: Material Damage
        script: 4 Scoring File PSI.sas
        """

        # creating library, that is to be used internally in the SAS script to be executed
        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)
        self.sas_client.saslib("mdl_prir", path=self.mdl_prir)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "4 Scoring File PSI.sas")
        ) as file:
            code = file.read()

        # passing the values of variables, to be used inside the SAS script
        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")
        params = {
            "last_folder": self.last_folder,
            "year": folder_date.year,
            "saveLoc": self.saveLoc,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS4.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_path = os.path.join(
            self.lob_output_dir, f"{self.last_folder}", "PSI Scoring.pdf"
        )
        if os.path.isfile(output_file_path):
            self.logger.log("SAS script 4 executed successfully")
            self.logger.log(
                f"Output: {self.last_folder}", "PSI Scoring.pdf", color=Fore.YELLOW
            )

    @calculate_time
    @handle_error
    def step_5(self):
        """
        lob: Material Damage
        script: 5 2025 Scoring
        """
        self.logger.log("Importing Data...")
        df_path = os.path.join(self.lob_output_dir, "CBscoringv2.csv")
        df = pd.read_csv(df_path, index_col="SVC_REQ_NR")

        df.loc[
            df["ADJ_POS_DC"] == "Catastrophe Material Damage Adjuster", "ADJ_POS_DC"
        ] = "Material Damage Adjuster"

        # CONVERT TO NUMERIC
        df["salvage_acpt"] = df["SLVG_ASGN_ACPT_IN"].apply(
            lambda x: 1 if x == "Y" else 0
        )
        df["veh_opr"] = df["VEH_OPR_IN"].apply(
            lambda x: 1 if x == "Y" else (0 if x == "N" else -1)
        )
        df["drivetime2"] = df.apply(
            lambda x: (
                x["drivetime"]
                if x["SEL_APPR_TYP_DC"] == "MaterialDamageAdjuster"
                else -1
            ),
            axis=1,
        )
        df["veh_use_business"] = df["Veh_USE_RSN_DC_grp"].apply(
            lambda x: 1 if x == "Business" else 0
        )
        df["common_veh"] = df["make_grp"].apply(lambda x: 1 if x == "common" else 0)

        # DEPENDENT VARIABLE
        yCol = ["elaps2"]
        # X VARIABLES - start with those that survived boruta
        xCol = [
            # nuisance
            "USR_RPT_BRNCH_DC",
            # vehicle info
            "veh_age",
            "lien_lease",
            "veh_opr",
            "common_veh",
            "VEH_STYL_DC_grp",
            "veh_use_business",
            # service area info
            "vehicles_in_20mi",
            "br_pos_emp_count",
            "drivetime",
            # incident info
            "coll_pnt_grp",
            "DRVR_INSD_REL_TYP_DC",
            "LOB_grp",
            # appraisal info
            "SEL_APPR_TYP_DC",
            "monthc",
            # workload
            "Salvage",
            "DirectRepairProgram",
            "MaterialDamageAdjuster",
            "IndependentAdjuster",
            "EstimateDeskReview",
            "OpenShop",
            "PhotoAppraisal",
        ]

        # CREATE X & Y DATA
        x = df[xCol]
        y = df[yCol]

        # MISSING NUMERICS WILL BE ASSIGEND -1
        x.fillna(-1, inplace=True)

        # FLAG CATEGORICAL COLUMNS - NECESSARY TO UNLEACH CATBOOST POWER!
        categorical_features_indices = np.where(x.dtypes != np.float64)[0]

        # CREATE TRAIN TEST SPLITS
        xtrain, xtest, ytrain, ytest = train_test_split(
            x, y, train_size=0.50, random_state=1234
        )

        # CREATE A DATA POOLS
        trainPool = cb.Pool(xtrain, ytrain, cat_features=categorical_features_indices)
        testPool = cb.Pool(xtest, ytest, cat_features=categorical_features_indices)

        self.logger.log("Importing python Model...")
        # import current model

        modelh = cb.CatBoostRegressor()
        modelh.load_model(
            os.path.join(
                os.path.split(self.sas_scripts_path)[0], "Source", "MDAv11noyear"
            )
        )

        # MAKE SURE ALL Xs ARE PREPARED EXACTLY THE SAME WAY AS WHEN THE DATA WAS MODELED
        # THE RECORDS FROM THE ORIGINAL DATASET (df) AND "x series" MUST PRESERVE ORDER INTEGRITY (nth RECORD IN df & x must be the same)
        # CREATE A COPY OF ORIGINAL DATASET
        # MUST CONTAIN ALL RECORDS IN THE SAME ORDER AS THE "x series"4
        scored = df.copy()

        # MAKE A PREDICTION ON ENTIRE Xs
        predAll = modelh.predict(x)

        # APPEND SCORE TO DATASET
        scored["pred"] = predAll[:]

        # make index a column so that can keep in merge below
        scored["drpno"] = scored.index
        scored = scored[["drpno", "pred"]]

        # check one record, should be: 1.614354 for v11
        scored.loc[scored["drpno"] == 7811004]

        # CREATE A SHAP TREE EXPLAINER FOR THE MODEL
        explainer = shap.TreeExplainer(modelh)
        # CREATE SHAP VALUES FOR ALL Xs
        sValues = explainer.shap_values(x)

        # OVERALL MEAN PREDICTIONS - ALL SHAP VALUES DEVIATE FROM THIS
        meanPred = explainer.expected_value

        # CONVERT SHAP VALUES TO DATAFRAME
        shapDf = pd.DataFrame(sValues, columns=[x.columns.tolist()])

        # ADD ON MEAN PREDICTION
        shapDf["baseline_mean"] = meanPred

        # IGNORE INDEX (NEED TO MAINTAIN ROW SORTING INTEGRITY HERE)
        scored.reset_index(drop=True, inplace=True)
        shapDf.reset_index(drop=True, inplace=True)
        # MERGE ON SHAP VALUES
        scoredShap = pd.concat([scored, shapDf], axis=1, sort=False)

        self.logger.log("Exporting Output...")
        output_file_path = os.path.join(self.lob_output_dir, "model_out.csv")
        # EXPORT
        scoredShap.to_csv(output_file_path)

        self.logger.log("Python model executed successfully")

        # Checking whether the output generated in the designated folder or not.
        if os.path.isfile(output_file_path):
            self.logger.log("SAS script 5 executed successfully")
            self.logger.log("Output: model_out.csv", color=Fore.YELLOW)

    @calculate_time
    @handle_error
    def step_6(self):
        """
        lob: Material Damage
        script: 6 Import and Prep Python Output v2 Superfile Fixes.sas
        """

        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)
        self.sas_client.saslib("src", path=self.src)

        # fetch code from the SAS Script
        with open(
            os.path.join(
                self.sas_scripts_path,
                "6 Import and Prep Python Output v2 Superfile Fixes.sas",
            )
        ) as file:
            code = file.read()

        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")
        params = {
            "last_folder": self.last_folder,
            "year": folder_date.year,
            "flag": self.flag,
            "output_path_csv": self.mdl_curr,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS6.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["QlikAdjustments SAS_md.xlsx", "QlikSuperfile_md.xlsx"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 6 executed successfully")
            self.logger.log(
                "Output: QlikAdjustments SAS_md.xlsx and QlikSuperfile_md.xlsx",
                color=Fore.YELLOW,
            )


class MaterialDamageV2(BaseLOB):

    def get_lob_name(self):
        return "Material Damage V2"

    def get_script_names(self) -> List[str]:
        return [
            "1 Combine Hours and Counts Data.sas",
            "2 Adjuster Addresses v2.sas",
            "3 New MDA Data Pull v2.sas",
            "4 Scoring File PSI.sas",
            "6 Import and Prep Python Output v2 Superfile Fixes.sas",
        ]

    def get_output_file_names(self) -> List[str]:
        return [
            "QlikAdjustments SAS_md.xlsx",
            "QlikSuperfile_md.xlsx",
        ]

    def initialize_variables_for_sas(self):
        if self.path_type == "local":
            self.mdl_curr = self.lib_path
            self.mdl_prir = self.lib_path
            self.saveLoc = self.lib_path
        else:
            self.mdl_curr = convert_path_to_lib(self.lib_path)
            prior_dt_path = os.path.abspath(
                os.path.join(
                    self.grand_dir,
                    self.get_lob_name(),
                    f"{self.year_prior}",
                    self.folder_dt_prior,
                )
            )
            self.mdl_prir = convert_path_to_lib(prior_dt_path)
            self.saveLoc = self.lob_output_dir
        self.src = convert_path_to_lib(
            os.path.join(os.path.split(self.sas_scripts_path)[0], "Source")
        )
        self.logger.log(f"self.src: {self.src}")

    @calculate_time
    @handle_error
    def step_1(self):
        """
        lob: Material Damage
        script: 1 Combine Hours and Counts Data.sas
        """
        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "1 Combine Hours and Counts Data.sas")
        ) as file:
            code = file.read()

        # calculating the value of cut off and end ppd date that are to be used inside the SAS script
        cutoff = datetime.strptime(self.last_folder, "%m-%d-%Y") - timedelta(
            days=(3 * 365) + (7 * 30)
        )
        cutoff = cutoff.replace(day=1)
        self.cutoff = cutoff.strftime("%m-%d-%Y")

        params = {
            "endppd": self.last_folder,
            "cutoff": self.cutoff,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS1.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["adj_decode.sas7bdat", "hcoutput.sas7bdat"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 1 executed successfully")
            self.logger.log(
                "Output: adj_decode.sas7bdat and hcoutput.sas7bdat", color=Fore.YELLOW
            )

    @calculate_time
    @handle_error
    def step_2(self):
        """
        lob: Material Damage
        script: 2 Adjuster Addresses v2.sas
        """
        # creating library, that is to be used internally in the SAS script to be executed
        self.sas_client.saslib("src", path=self.src)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "2 Adjuster Addresses v2.sas")
        ) as file:
            code = file.read()

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS2.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        self.logger.log("SAS script 2 executed successfully")
        self.logger.log("Output: No Physical file", color=Fore.YELLOW)

    @calculate_time
    @handle_error
    def step_3(self):
        """
        lob: Material Damage
        script: 3 New MDA Data Pull v2.sas
        """
        # Adjusting the format of date as per the requirement of the program

        frm_dt = datetime.strptime(self.cutoff, "%m-%d-%Y")
        frm_dt = frm_dt.strftime("%d%B%Y").upper()
        frm_dt = f"{frm_dt}:00:00:00"

        to_dt = datetime.strptime(self.last_folder, "%m-%d-%Y")
        to_dt = to_dt.strftime("%d%B%Y").upper()
        to_dt = f"{to_dt}:23:59:59"

        frm_dt = f"'{frm_dt}'"
        to_dt = f"'{to_dt}'"

        # creating library, that is to be used internally in the SAS script to be executed
        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)
        self.sas_client.saslib("src", path=self.src)
        # fetch code from the SAS Script
        with open(
            os.path.join(
                self.sas_scripts_path,
                "3 New MDA Data Pull v2.sas",
            )
        ) as file:
            code = file.read()

        # passing the values of variables, to be used inside the SAS script
        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")
        params = {
            "last_folder": self.last_folder,
            "year": folder_date.year,
            "from_dt": frm_dt,
            "to_dt": to_dt,
            "flag": self.flag,
            "output_path_csv": self.mdl_curr,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS3.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["CBscoringv2.csv", "for_pythonscoring.sas7bdat"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 3 executed successfully")
            self.logger.log(
                "Output: CBscoringv2.csv and for_pythonscoring.sas7bdat",
                color=Fore.YELLOW,
            )

    @calculate_time
    @handle_error
    def step_4(self):
        """
        lob: Material Damage
        script: 4 Scoring File PSI.sas
        """

        # creating library, that is to be used internally in the SAS script to be executed
        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)
        self.sas_client.saslib("mdl_prir", path=self.mdl_prir)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "4 Scoring File PSI.sas")
        ) as file:
            code = file.read()

        # passing the values of variables, to be used inside the SAS script
        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")
        params = {
            "last_folder": self.last_folder,
            "year": folder_date.year,
            "saveLoc": self.saveLoc,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS4.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_path = os.path.join(
            self.lob_output_dir, f"{self.last_folder}", "PSI Scoring.pdf"
        )
        if os.path.isfile(output_file_path):
            self.logger.log("SAS script 4 executed successfully")
            self.logger.log(
                f"Output: {self.last_folder}", "PSI Scoring.pdf", color=Fore.YELLOW
            )

    @calculate_time
    @handle_error
    def step_5(self):
        """
        lob: Material Damage
        script: 5 2025 Scoring
        """
        self.logger.log("Importing Data...")
        df_path = os.path.join(self.lob_output_dir, "CBscoringv2.csv")
        df = pd.read_csv(df_path, index_col="SVC_REQ_NR")

        self.logger.log(f"# of records: {df.shape[0]}")
        self.logger.log(f"# of columns: {df.shape[1]}")

        df["veh_opr"] = df["VEH_OPR_IN"].apply(
            lambda x: 1 if x == "Y" else (0 if x == "N" else -1)
        )
        df["common_veh"] = df["make_grp"].apply(lambda x: 1 if x == "common" else 0)

        # MISSING NUMERICS WILL BE ASSIGEND -1
        df.fillna(-1, inplace=True)

        # FLAG CATEGORICAL COLUMNS - NECESSARY TO UNLEACH CATBOOST POWER!
        categorical_features_indices = np.where(df.dtypes != float)[0]

        # make it a test pool, run through model
        scrpl = cb.Pool(df, cat_features=categorical_features_indices)

        self.logger.log("Importing python Model...")
        # import current model

        modelh = cb.CatBoostRegressor()
        modelh.load_model(
            os.path.join(os.path.split(self.sas_scripts_path)[0], "Source", "MDAv21")
        )

        # MAKE A PREDICTION ON ENTIRE Xs
        pred = modelh.predict(scrpl)

        # # APPEND SCORE TO DATASET
        df["pred"] = pred[:]

        # # make index a column so that can keep in merge below
        df["drpno"] = df.index
        scored = df[["drpno", "pred"]]

        xCol = [
            # nuisance
            "USR_RPT_BRNCH_DC",
            # vehicle info
            "veh_age",
            "lien_lease",
            "veh_opr",
            "common_veh",
            "VEH_STYL_DC_grp",
            # service area info
            "vehicles_in_20mi",
            "br_pos_emp_count",
            "drivetime",
            # incident info
            "coll_pnt_grp",
            "DRVR_INSD_REL_TYP_DC",
            "LOB_grp",
            # appraisal info
            "SEL_APPR_TYP_DC",
            "monthc",
            # workload
            "DirectRepairProgram",
            "MaterialDamageAdjuster",
            "IndependentAdjuster",
            "EstimateDeskReview",
            "PhotoAppraisal",
            # evaluate
            "supplements",
            "has_rental",
        ]

        x = df[xCol]

        # CREATE A SHAP TREE EXPLAINER FOR THE MODEL
        explainer = shap.TreeExplainer(modelh)
        # CREATE SHAP VALUES FOR ALL Xs
        sValues = explainer.shap_values(x)

        # OVERALL MEAN PREDICTIONS - ALL SHAP VALUES DEVIATE FROM THIS
        meanPred = explainer.expected_value

        # CONVERT SHAP VALUES TO DATAFRAME
        shapDf = pd.DataFrame(sValues, columns=[x.columns.tolist()])

        # ADD ON MEAN PREDICTION
        shapDf["baseline_mean"] = meanPred

        # IGNORE INDEX (NEED TO MAINTAIN ROW SORTING INTEGRITY HERE)
        scored.reset_index(drop=True, inplace=True)
        shapDf.reset_index(drop=True, inplace=True)
        # MERGE ON SHAP VALUES
        scoredShap = pd.concat([scored, shapDf], axis=1, sort=False)

        self.logger.log("Exporting Output...")
        output_file_path = os.path.join(self.lob_output_dir, "model_out.csv")
        # EXPORT
        scoredShap.to_csv(output_file_path)

        self.logger.log("Python model executed successfully")

        # Checking whether the output generated in the designated folder or not.
        if os.path.isfile(output_file_path):
            self.logger.log("SAS script 5 executed successfully")
            self.logger.log("Output: model_out.csv", color=Fore.YELLOW)

    @calculate_time
    @handle_error
    def step_6(self):
        """
        lob: Material Damage
        script: 6 Import and Prep Python Output v2 Superfile Fixes.sas
        """

        self.sas_client.saslib("mdl_curr", path=self.mdl_curr)
        self.sas_client.saslib("src", path=self.src)

        # fetch code from the SAS Script
        with open(
            os.path.join(
                self.sas_scripts_path,
                "6 Import and Prep Python Output v2 Superfile Fixes.sas",
            )
        ) as file:
            code = file.read()

        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")
        params = {
            "last_folder": self.last_folder,
            "year": folder_date.year,
            "flag": self.flag,
            "output_path_csv": self.mdl_curr,
        }
        # passing the values of the different variables that are to be used internally inside the script
        self.logger.log(f"Input parameters to the script: {params}")
        for prm_name, prm_val in params.items():
            self.sas_client.symput(prm_name, prm_val)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.join(self.lob_output_dir, "Log_SAS6.txt")
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["QlikAdjustments SAS_md.xlsx", "QlikSuperfile_md.xlsx"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 6 executed successfully")
            self.logger.log(
                "Output: QlikAdjustments SAS_md.xlsx and QlikSuperfile_md.xlsx",
                color=Fore.YELLOW,
            )

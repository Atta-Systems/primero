import React from "react";
import { useSelector } from "react-redux";
import PropTypes from "prop-types";
import CheckIcon from "@material-ui/icons/Check";
import CloseIcon from "@material-ui/icons/Close";

import { useI18n } from "../../../../../i18n";
import { getSavingRecord } from "../../selectors";
import { FormAction } from "../../../../../form";

import { NAME } from "./constants";

const Component = ({ formMode, handleSubmit, handleCancel }) => {
  const i18n = useI18n();
  const saving = useSelector(state => getSavingRecord(state));
  const saveButton = (formMode.get("isEdit") || formMode.get("isNew")) && (
    <>
      <FormAction cancel actionHandler={handleCancel} text={i18n.t("buttons.cancel")} startIcon={<CloseIcon />} />
      <FormAction
        actionHandler={handleSubmit}
        text={i18n.t("buttons.save")}
        startIcon={<CheckIcon />}
        savingRecord={saving}
      />
    </>
  );

  return saveButton;
};

Component.displayName = NAME;

Component.propTypes = {
  formMode: PropTypes.object.isRequired,
  handleCancel: PropTypes.func.isRequired,
  handleSubmit: PropTypes.func.isRequired
};

export default Component;

import React, { useEffect } from "react";
import PropTypes from "prop-types";
import { FormContext, useForm } from "react-hook-form";
import isEqual from "lodash/isEqual";

import { getShortIdFromUniqueId } from "../../../../../../records/utils";
import { MODES, RECORD_PATH } from "../../../../../../../config";
import { whichFormMode } from "../../../../../../form";
import FormSection from "../../../../../../form/components/form-section";
import TraceActions from "../trace-actions";
import { FORMS } from "../../constants";

import { NAME } from "./constants";

const Component = ({ setSelectedForm, traceValues, formSection, recordType, selectedForm, handleClose }) => {
  const formMode = whichFormMode(MODES.show);
  // eslint-disable-next-line camelcase
  const caseId = traceValues?.matched_case_id;
  const values = caseId ? { ...traceValues, matched_case_id: getShortIdFromUniqueId(caseId) } : traceValues;
  const methods = useForm({ defaultValues: values || {} });

  const index = formSection.fields.findIndex(field => field.name === "matched_case_id");
  const formSectionToRender = formSection
    .setIn(["fields", index, "type"], "link_field")
    .setIn(["fields", index, "href"], `/${RECORD_PATH.cases}/${caseId}`);

  useEffect(() => {
    const currentValues = methods.getValues();

    if (!isEqual(currentValues, values)) {
      methods.reset(values);
    }
  }, [traceValues]);

  const handleConfirm = () => setSelectedForm(FORMS.matches);

  return (
    <>
      <TraceActions
        handleBack={handleClose}
        handleConfirm={handleConfirm}
        selectedForm={selectedForm}
        hasMatch={Boolean(traceValues.matched_case_id)}
        recordType={recordType}
      />
      <FormContext {...methods} formMode={formMode}>
        <FormSection formSection={formSectionToRender} showTitle={false} disableUnderline />
      </FormContext>
    </>
  );
};

Component.propTypes = {
  formSection: PropTypes.object.isRequired,
  handleClose: PropTypes.func,
  recordType: PropTypes.string.isRequired,
  selectedForm: PropTypes.string,
  setSelectedForm: PropTypes.func,
  traceValues: PropTypes.object
};

Component.displayName = NAME;

export default Component;
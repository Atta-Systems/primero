import React from "react";
import PropTypes from "prop-types";
import { FieldArray, connect } from "formik";

import { useI18n } from "../../../i18n";
import { constructInitialValues } from "../../helpers";

import SubformFieldArray from "./SubformFieldArray";

const SubformField = ({ field, formik, mode }) => {
  const { name, subform_section_id: subformSectionID } = field;

  const i18n = useI18n();

  const initialSubformValue = constructInitialValues([subformSectionID]);

  return (
    <>
      <FieldArray name={name}>
        {arrayHelpers => (
          <SubformFieldArray
            arrayHelpers={arrayHelpers}
            field={field}
            mode={mode}
            initialSubformValue={initialSubformValue}
            i18n={i18n}
            formik={formik}
          />
        )}
      </FieldArray>
    </>
  );
};

SubformField.propTypes = {
  field: PropTypes.object.isRequired,
  formik: PropTypes.object.isRequired,
  mode: PropTypes.object.isRequired
};

export default connect(SubformField);
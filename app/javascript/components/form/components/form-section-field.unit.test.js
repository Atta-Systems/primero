import React from "react";
import Alert from "@material-ui/lab/Alert";
import { FormContext } from "react-hook-form";
import { fromJS } from "immutable";

import { setupMockFormComponent } from "../../../test";
import { FieldRecord } from "../records";
import { RADIO_FIELD, TOGGLE_FIELD, DIALOG_TRIGGER } from "../constants";

import FormSectionField from "./form-section-field";

describe("<Form /> - components/<FormSectionField />", () => {
  it("renders a text field", () => {
    const field = FieldRecord({ name: "test_field", type: "text_field" });
    const { component } = setupMockFormComponent(FormSectionField, { field });

    expect(component.exists("input[name='test_field']")).to.be.true;
  });

  it("renders a textarea field", () => {
    const field = FieldRecord({ name: "test_field", type: "textarea" });
    const { component } = setupMockFormComponent(FormSectionField, { field });

    expect(component.exists("textarea[name='test_field']")).to.be.true;
  });

  it("renders an error field", () => {
    const field = FieldRecord({ name: "test_field", type: "error_field" });
    const { component } = setupMockFormComponent(() => (
      <FormContext errors={{ name: "test" }} formMode={fromJS({})}>
        <FormSectionField field={field} checkErrors={fromJS(["name"])} />
      </FormContext>
    ));

    expect(component.find(Alert)).to.have.lengthOf(1);
  });

  it("does not render an error field", () => {
    const field = FieldRecord({ name: "test_field", type: "error_field" });
    const { component } = setupMockFormComponent(() => (
      <FormContext formMode={fromJS({})}>
        <FormSectionField field={field} checkErrors={fromJS(["name"])} />
      </FormContext>
    ));

    expect(component.find(Alert)).to.be.empty;
  });

  it("renders a radio button field", () => {
    const field = FieldRecord({
      name: "radio_test_field",
      type: RADIO_FIELD,
      option_strings_text: {
        en: [
          {
            id: "yes",
            label: "Yes"
          },
          {
            id: "no",
            label: "No"
          }
        ]
      }
    });
    const { component } = setupMockFormComponent(FormSectionField, { field });

    expect(component.exists("input[name='radio_test_field']")).to.be.true;
  });

  it("renders a toggle field", () => {
    const field = FieldRecord({ name: "test_field", type: TOGGLE_FIELD });
    const { component } = setupMockFormComponent(FormSectionField, { field });

    expect(component.exists("input[name='test_field']")).to.be.true;
  });

  it("renders a buttons link", () => {
    const field = FieldRecord({ name: "test_field", type: DIALOG_TRIGGER, display_name: { en: "Test Field" } });
    const { component } = setupMockFormComponent(FormSectionField, { field });
    const buttonLink = component.find("a");

    expect(buttonLink).to.have.lengthOf(1);
    expect(buttonLink.text()).to.be.equal("Test Field");
  });
});

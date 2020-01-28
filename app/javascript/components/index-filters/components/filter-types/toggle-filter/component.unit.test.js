import { setupMockFormComponent, expect } from "../../../../../test";

import ToggleFilter from "./component";

describe("<ToggleFilter>", () => {
  const filter = {
    field_name: "filter",
    name: "Filter 1",
    options: {
      en: [
        { id: "option-1", display_text: "Option 1" },
        { id: "option-2", display_text: "Option 2" }
      ]
    }
  };

  const props = {
    filter
  };

  it("renders panel", () => {
    const { component } = setupMockFormComponent(ToggleFilter, props);

    expect(component.exists("Panel")).to.be.true;
  });

  it("renders toggle buttons", () => {
    const { component } = setupMockFormComponent(ToggleFilter, props);

    ["option-1", "option-2"].forEach(
      option => expect(component.exists(`button[value='${option}']`)).to.be.true
    );
  });

  it("renders select as secondary filter, with valid pros in the more section", () => {
    const newProps = {
      isSecondary: true,
      moreSectionFilters: {},
      setMoreSectionFilters: () => {},
      filter
    };
    const { component } = setupMockFormComponent(ToggleFilter, newProps);
    const clone = { ...component.find(ToggleFilter).props() };

    ["option-1", "option-2"].forEach(
      option => expect(component.exists(`button[value='${option}']`)).to.be.true
    );

    [
      "isSecondary",
      "moreSectionFilters",
      "setMoreSectionFilters",
      "filter",
      "commonInputProps"
    ].forEach(property => {
      expect(clone).to.have.property(property);
      delete clone[property];
    });

    expect(clone).to.be.empty;
  });
});
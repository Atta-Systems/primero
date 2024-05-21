// Copyright (c) 2014 - 2023 UNICEF. All rights reserved.

import * as constants from "./constants";

describe("Verifying config constant", () => {
  it("should have known constant", () => {
    const clonedConstants = { ...constants };

    ["NAME", "NEW"].forEach(property => {
      expect(clonedConstants).to.have.property(property);
      delete clonedConstants[property];
    });

    expect(clonedConstants).to.be.empty;
  });
});

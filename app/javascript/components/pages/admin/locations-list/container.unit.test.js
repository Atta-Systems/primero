import { fromJS } from "immutable";

import { setupMountedComponent, listHeaders, lookups, stub } from "../../../../test";
import IndexTable from "../../../index-table";
import { ACTIONS } from "../../../../libs/permissions";
import { FiltersForm } from "../../../form-filters/components";
import InternalAlert from "../../../internal-alert";

import NAMESPACE from "./namespace";
import actions from "./actions";
import ImportDialog from "./import-dialog";
import LocationsList from "./container";

describe("<LocationsList />", () => {
  let stubI18n = null;
  let component;
  const dataLength = 30;
  const data = Array.from({ length: dataLength }, (_, i) => ({
    id: i + 1,
    name: { en: `Location ${i + 1}` }
  }));

  beforeEach(() => {
    stubI18n = stub(window.I18n, "t")
      .withArgs("messages.record_list.of")
      .returns("of")
      .withArgs("location.no_location")
      .returns("No Location");
    const initialState = fromJS({
      records: {
        admin: {
          locations: {
            data,
            metadata: { total: dataLength, per: 20, page: 1 },
            loading: false,
            errors: false
          }
        }
      },
      forms: {
        options: {
          lookups: lookups()
        }
      },
      user: {
        permissions: {
          metadata: [ACTIONS.MANAGE]
        },
        listHeaders: {
          locations: listHeaders(NAMESPACE)
        }
      }
    });

    ({ component } = setupMountedComponent(LocationsList, {}, initialState, ["/admin/locations"]));
  });

  it("renders record list table", () => {
    expect(component.find(IndexTable)).to.have.lengthOf(1);
  });

  it("renders <FiltersForm /> component", () => {
    expect(component.find(FiltersForm)).to.have.lengthOf(1);
  });

  it("renders <ImportDialog /> component", () => {
    expect(component.find(ImportDialog)).to.have.lengthOf(1);
  });

  it("should trigger a valid action with next page when clicking next page", () => {
    const indexTable = component.find(IndexTable);
    const expectAction = {
      api: {
        params: fromJS({ total: dataLength, per: 20, page: 2, disabled: ["false"], hierarchy: true }),
        path: NAMESPACE
      },
      type: actions.LOCATIONS
    };

    expect(indexTable.find("p").at(2).text()).to.be.equals(`1-20 of ${dataLength}`);
    expect(component.props().store.getActions()).to.have.lengthOf(1);

    indexTable.find("#pagination-next").at(0).simulate("click");

    expect(indexTable.find("p").at(2).text()).to.be.equals(`21-${dataLength} of ${dataLength}`);
    expect(component.props().store.getActions()[1].api.params.toJS()).to.deep.equals(expectAction.api.params.toJS());
    expect(component.props().store.getActions()[1].type).to.deep.equals(expectAction.type);
    expect(component.props().store.getActions()[1].api.path).to.deep.equals(expectAction.api.path);
  });

  afterEach(() => {
    if (stubI18n) {
      window.I18n.t.restore();
    }
  });

  describe("when no location loaded", () => {
    beforeEach(() => {
      const initialState = fromJS({
        records: {
          admin: {
            locations: {
              data: [],
              metadata: { total: 0, per: 20, page: 1 },
              loading: false,
              errors: false
            }
          }
        },
        user: {
          permissions: {
            metadata: [ACTIONS.MANAGE]
          },
          listHeaders: {
            locations: listHeaders(NAMESPACE)
          }
        }
      });

      ({ component } = setupMountedComponent(LocationsList, {}, initialState, ["/admin/locations"]));
    });

    it("renders InternalAlert alert", () => {
      expect(component.find(InternalAlert).text()).to.equal("No Location");
      expect(component.find(InternalAlert)).to.have.lengthOf(1);
    });
  });
});
// Copyright (c) 2014 - 2023 UNICEF. All rights reserved.

import { useEffect } from "react";
import { fromJS, List } from "immutable";
import AddIcon from "@mui/icons-material/Add";
import { Link } from "react-router-dom";
import Grid from "@mui/material/Unstable_Grid2";
import { useDispatch } from "react-redux";

import { useI18n } from "../../../i18n";
import IndexTable from "../../../index-table";
import { PageHeading, PageContent } from "../../../page";
import { ROUTES } from "../../../../config";
import { NAMESPACE } from "../roles-form";
import { getAppliedFilters, getMetadata } from "../../../record-list";
import ActionButton from "../../../action-button";
import { ACTION_BUTTON_TYPES } from "../../../action-button/constants";
import { usePermissions, RESOURCES, CREATE_RECORDS } from "../../../permissions";
import { useMetadata } from "../../../records";
import { useApp } from "../../../application";
import { useMemoizedSelector } from "../../../../libs";
import { FiltersForm } from "../../../form-filters/components";
import { DEFAULT_FILTERS, DATA, DISABLED } from "../constants";
import { filterOnTableChange, getFilters, onSubmitFilters } from "../utils";

import { fetchRoles, setRolesFilter } from "./action-creators";
import { ADMIN_NAMESPACE, LIST_HEADERS, NAME } from "./constants";

function Container() {
  const i18n = useI18n();
  const dispatch = useDispatch();
  const { limitedProductionSite } = useApp();
  const recordType = RESOURCES.roles;

  const columns = LIST_HEADERS.map(({ label, ...rest }) => ({
    label: i18n.t(label),
    ...rest
  }));
  const metadata = useMemoizedSelector(state => getMetadata(state, "roles"));
  const currentFilters = useMemoizedSelector(state => getAppliedFilters(state, [ADMIN_NAMESPACE, NAMESPACE]));

  const defaultFilters = fromJS(DEFAULT_FILTERS).merge(metadata);
  const canAddRoles = usePermissions(NAMESPACE, CREATE_RECORDS);
  const rolesNewButton = canAddRoles && (
    <ActionButton
      icon={<AddIcon />}
      text="buttons.new"
      type={ACTION_BUTTON_TYPES.default}
      rest={{
        to: ROUTES.admin_roles_new,
        component: Link,
        hide: limitedProductionSite
      }}
    />
  );

  useMetadata(recordType, metadata, fetchRoles, DATA, { defaultFilterFields: DEFAULT_FILTERS });

  const onSubmit = data =>
    onSubmitFilters(currentFilters.merge(fromJS(data || DEFAULT_FILTERS)), dispatch, fetchRoles, setRolesFilter);

  const onTableChange = filterOnTableChange(dispatch, fetchRoles, setRolesFilter);

  const filterProps = {
    clearFields: [DISABLED],
    filters: getFilters(i18n),
    onSubmit,
    defaultFilters,
    initialFilters: DEFAULT_FILTERS
  };

  const tableOptions = {
    recordType: [ADMIN_NAMESPACE, NAMESPACE],
    columns: List(columns),
    options: {
      selectableRows: "none"
    },
    defaultFilters,
    onTableChange,
    targetRecordType: NAMESPACE,
    bypassInitialFetch: true
  };

  useEffect(() => {
    dispatch(setRolesFilter({ data: defaultFilters }));
  }, []);

  return (
    <>
      <PageHeading title={i18n.t("roles.label")}>{rolesNewButton}</PageHeading>
      <PageContent>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={8}>
            <IndexTable title={i18n.t("roles.label")} {...tableOptions} />
          </Grid>
          <Grid item xs={12} sm={4}>
            <FiltersForm {...filterProps} noMargin />
          </Grid>
        </Grid>
      </PageContent>
    </>
  );
}

Container.displayName = NAME;

export default Container;

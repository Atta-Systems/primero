import React from "react";
import { fromJS, List } from "immutable";
import { Button } from "@material-ui/core";
import AddIcon from "@material-ui/icons/Add";
import { Link } from "react-router-dom";

import { useI18n } from "../../../i18n";
import IndexTable from "../../../index-table";
import { PageHeading, PageContent } from "../../../page";
import { ROUTES } from "../../../../config";
import { NAMESPACE } from "../roles-form";
import { useThemeHelper } from "../../../../libs";
import styles from "../styles.css";
import ButtonText from "../../../button-text";

import { fetchRoles } from "./action-creators";
import { ADMIN_NAMESPACE, LIST_HEADERS, NAME } from "./constants";

const Container = () => {
  const i18n = useI18n();
  const { css } = useThemeHelper(styles);

  const columns = LIST_HEADERS.map(({ label, ...rest }) => ({
    label: i18n.t(label),
    ...rest
  }));

  const tableOptions = {
    recordType: [ADMIN_NAMESPACE, NAMESPACE],
    columns: List(columns),
    options: {
      selectableRows: "none"
    },
    defaultFilters: fromJS({
      per: 20,
      page: 1
    }),
    onTableChange: fetchRoles,
    targetRecordType: NAMESPACE
  };

  return (
    <>
      <PageHeading title={i18n.t("roles.label")}>
        <Button
          to={ROUTES.admin_roles_new}
          component={Link}
          color="primary"
          className={css.showActionButton}
        >
          <AddIcon />
          <ButtonText text={i18n.t("buttons.new")} />
        </Button>
      </PageHeading>
      <PageContent>
        <IndexTable {...tableOptions} />
      </PageContent>
    </>
  );
};

Container.displayName = NAME;

export default Container;

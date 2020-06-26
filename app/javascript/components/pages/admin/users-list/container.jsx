import React from "react";
import { fromJS } from "immutable";
import { Button } from "@material-ui/core";
import AddIcon from "@material-ui/icons/Add";
import { Link } from "react-router-dom";

import { useI18n } from "../../../i18n";
import IndexTable from "../../../index-table";
import { PageHeading, PageContent } from "../../../page";
import { ROUTES } from "../../../../config";
import { usePermissions } from "../../../user";
import NAMESPACE from "../namespace";
import { CREATE_RECORDS } from "../../../../libs/permissions";
import { useThemeHelper } from "../../../../libs";
import styles from "../styles.css";
import ButtonText from "../../../button-text";

import { fetchUsers } from "./action-creators";
import { LIST_HEADERS } from "./constants";

const Container = () => {
  const i18n = useI18n();
  const canAddUsers = usePermissions(NAMESPACE, CREATE_RECORDS);
  const recordType = "users";
  const { css } = useThemeHelper(styles);

  const columns = LIST_HEADERS.map(({ label, ...rest }) => ({
    label: i18n.t(label),
    ...rest
  }));

  const tableOptions = {
    recordType,
    columns,
    options: {
      selectableRows: "none"
    },
    defaultFilters: fromJS({
      per: 20,
      page: 1
    }),
    onTableChange: fetchUsers
  };

  const newUserBtn = canAddUsers && (
    <Button
      to={ROUTES.admin_users_new}
      component={Link}
      color="primary"
      className={css.showActionButton}
    >
      <AddIcon />
      <ButtonText text={i18n.t("buttons.new")} />
    </Button>
  );

  return (
    <>
      <PageHeading title={i18n.t("users.label")}>{newUserBtn}</PageHeading>
      <PageContent>
        <IndexTable {...tableOptions} />
      </PageContent>
    </>
  );
};

Container.displayName = "UsersList";

Container.propTypes = {};

export default Container;

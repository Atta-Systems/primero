import {
  Drawer,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  useMediaQuery
} from "@material-ui/core";
import React, { useEffect, useCallback } from "react";
import { NavLink } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";

import { AgencyLogo } from "../agency-logo";
import { ModuleLogo } from "../module-logo";
import { useI18n } from "../i18n";
import { useThemeHelper } from "../../libs";
import { MobileToolbar } from "../mobile-toolbar";
import { useApp } from "../application";
import { ListIcon } from "../list-icon";
import { Jewel } from "../jewel";
import { TranslationsToggle } from "../translations-toggle";

import { NAME } from "./constants";
import styles from "./styles.css";
import * as actions from "./action-creators";
import {
  selectDrawerOpen,
  selectUsername,
  selectUserAgency
} from "./selectors";

const Nav = () => {
  const { css, theme } = useThemeHelper(styles);
  const mobileDisplay = useMediaQuery(theme.breakpoints.down("sm"));
  const i18n = useI18n();
  const dispatch = useDispatch();

  const openDrawer = useCallback(value => dispatch(actions.openDrawer(value)), [
    dispatch
  ]);

  const { userModules } = useApp();
  const module = userModules.first();

  // TODO: Username should come from redux once user built.
  const username = useSelector(state => selectUsername(state));
  const agency = useSelector(state => selectUserAgency(state));
  const drawerOpen = useSelector(state => selectDrawerOpen(state));
  const nav = [
    { name: i18n.t("navigation.home"), to: "/dashboard", icon: "home" },
    {
      name: i18n.t("navigation.tasks"),
      to: "/tasks",
      icon: "tasks",
      jewelCount: 0
    },
    {
      name: i18n.t("navigation.cases"),
      to: "/cases",
      icon: "cases",
      jewelCount: 20
    },
    {
      name: i18n.t("navigation.incidents"),
      to: "/incidents",
      icon: "incidents",
      jewelCount: 0
    },
    {
      name: i18n.t("navigation.tracing_request"),
      to: "/tracing_requests",
      icon: "tracing_request"
    },
    {
      name: i18n.t("navigation.potential_match"),
      to: "/matches",
      icon: "matches"
    },
    { name: i18n.t("navigation.reports"), to: "/reports", icon: "reports" },
    {
      name: i18n.t("navigation.bulk_exports"),
      to: "/exports",
      icon: "exports"
    },
    {
      name: i18n.t("navigation.support"),
      to: "/support",
      icon: "support",
      divider: true
    },
    { name: username, to: "/account", icon: "account" },
    { name: i18n.t("navigation.logout"), to: "/logout", icon: "logout" }
  ];

  useEffect(() => {
    if (!mobileDisplay && !drawerOpen) {
      openDrawer(true);
    }
  }, [drawerOpen, mobileDisplay, openDrawer]);

  return (
    <>
      <MobileToolbar
        drawerOpen={drawerOpen}
        openDrawer={openDrawer}
        mobileDisplay={mobileDisplay}
      />
      <Drawer
        variant="persistent"
        anchor="left"
        open={drawerOpen}
        classes={{
          paper: css.drawerPaper
        }}
      >
        {!mobileDisplay && (
          <ModuleLogo
            moduleLogo={module ? module.unique_id : "primero"}
            username={username}
          />
        )}
        <List className={css.navList}>
          {nav.map(l => (
            <div key={l.to}>
              {l.divider && <div className={css.navSeparator} />}
              <ListItem key={l.to}>
                <NavLink
                  to={l.to}
                  className={css.navLink}
                  activeClassName={css.navActive}
                >
                  <ListItemIcon classes={{ root: css.listIcon }}>
                    <ListIcon icon={l.icon} />
                  </ListItemIcon>
                  <ListItemText
                    primary={l.name}
                    classes={{ primary: css.listText }}
                  />
                  {l.jewelCount ? (
                    <Jewel value={l.jewelCount} mobileDisplay={mobileDisplay} />
                  ) : null}
                </NavLink>
              </ListItem>
            </div>
          ))}
        </List>

        {agency && agency.get("logo") && (
          <AgencyLogo
            agency={agency && agency.get("unique_id")}
            logo={`${(agency.get("logo") &&
              agency.getIn(["logo", "small"], "")) ||
              ""}`}
          />
        )}
        {!mobileDisplay && <TranslationsToggle />}
      </Drawer>
    </>
  );
};

Nav.displayName = NAME;

export default Nav;
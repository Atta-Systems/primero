import React from "react";
import { useSelector } from "react-redux";
import makeStyles from "@material-ui/styles/makeStyles";
import {
  ExpansionPanelDetails,
  ExpansionPanelSummary
} from "@material-ui/core";
import ArrowIcon from "@material-ui/icons/KeyboardArrowRight";
import PropTypes from "prop-types";

import { useI18n } from "../i18n";
import RecordFormTitle from "../record-form/form/record-form-title";

import styles from "./styles.css";
import { selectTransitions } from "./selectors";
import AssignmentsSummary from "./assignments/AssignmentsSummary";
import AssignmentsDetails from "./assignments/AssignmentsDetails";
import TransferSummary from "./transfers/TransferSummary";
import TransferDetails from "./transfers/TransferDetails";
import TransitionPanel from "./TransitionPanel";
import ReferralSummary from "./referrals/summary";
import TransferRequestSummary from "./transfer_requests/summary";
import TransferRequestDetails from "./transfer_requests/details";
import ReferralDetails from "./referrals/details";
import { TRANSITIONS_NAME } from "./constants";

const Transitions = ({
  isReferral,
  recordType,
  record,
  showMode,
  mobileDisplay,
  handleToggleNav
}) => {
  const css = makeStyles(styles)();
  const i18n = useI18n();

  const dataTransitions = useSelector(state =>
    selectTransitions(state, recordType, record, isReferral)
  );
  const renderSummary = transition => {
    switch (transition.type) {
      case "Assign":
        return <AssignmentsSummary transition={transition} classes={css} />;
      case "Transfer":
        return (
          <TransferSummary
            transition={transition}
            classes={css}
            showMode={showMode}
            recordType={recordType}
          />
        );
      case "Referral":
        return (
          <ReferralSummary
            transition={transition}
            classes={css}
            showMode={showMode}
            recordType={recordType}
          />
        );
      case "TransferRequest":
        return <TransferRequestSummary transition={transition} classes={css} />;
      default:
        return <h2>Not Found</h2>;
    }
  };

  const renderDetails = transition => {
    switch (transition.type) {
      case "Assign":
        return <AssignmentsDetails transition={transition} classes={css} />;
      case "Transfer":
        return <TransferDetails transition={transition} classes={css} />;
      case "Referral":
        return <ReferralDetails transition={transition} classes={css} />;
      case "TransferRequest":
        return <TransferRequestDetails transition={transition} classes={css} />;
      default:
        return <h2>Not Found</h2>;
    }
  };

  const renderTransition = transition => {
    return (
      <div key={transition.id}>
        <TransitionPanel key={transition.id} name={transition.id}>
          <ExpansionPanelSummary
            expandIcon={<ArrowIcon />}
            aria-controls="filter-controls-content"
            id={transition.id}
          >
            {renderSummary(transition)}
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            {renderDetails(transition)}
          </ExpansionPanelDetails>
        </TransitionPanel>
      </div>
    );
  };

  const renderDataTransitions =
    dataTransitions &&
    dataTransitions.map(transition => renderTransition(transition));

  const transitionTitle = isReferral
    ? i18n.t("forms.record_types.referrals")
    : i18n.t("transfer_assignment.title");

  return (
    <div>
      <RecordFormTitle
        mobileDisplay={mobileDisplay}
        handleToggleNav={handleToggleNav}
        displayText={transitionTitle}
      />
      {renderDataTransitions}
    </div>
  );
};

Transitions.displayName = TRANSITIONS_NAME;

Transitions.propTypes = {
  handleToggleNav: PropTypes.func.isRequired,
  isReferral: PropTypes.bool.isRequired,
  mobileDisplay: PropTypes.bool.isRequired,
  record: PropTypes.string.isRequired,
  recordType: PropTypes.string.isRequired,
  showMode: PropTypes.bool
};

export default Transitions;
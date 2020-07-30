import React from "react";
import PropTypes from "prop-types";

import { buttonType } from "./utils";
import { NAME } from "./constants";

const Component = ({
  icon,
  isCancel,
  isTransparent,
  pending,
  text,
  type,
  rest
}) => {
  const ButtonType = buttonType(type);

  return (
    <>
      <ButtonType
        icon={icon}
        isCancel={isCancel}
        isTransparent={isTransparent}
        pending={pending}
        rest={rest}
        text={text}
      />
    </>
  );
};

Component.displayName = NAME;

Component.propTypes = {
  icon: PropTypes.object,
  isCancel: PropTypes.bool,
  isTransparent: PropTypes.bool,
  pending: PropTypes.bool,
  rest: PropTypes.object,
  text: PropTypes.string,
  type: PropTypes.string.isRequired
};

export default Component;
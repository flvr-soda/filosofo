{
  # Make common variables available to all other flake-parts modules.
  # This acts as our single source of truth for user details and state versions.
  _module.args = {
    userName = "isma";
    userFullName = "Isma";
    userEmail = "iearmada@proton.me";
    gitName = "flvr-soda";
    stateVersion = "25.05";
  };
}

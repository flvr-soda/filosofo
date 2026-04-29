{
  config,
  userName,
  ...
}: {
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/${userName}/.ssh/id_ed25519"
  ];

  age.secrets.user-password = {
    file = ../../secrets/user-password.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  age.secrets.github-ssh-key = {
    file = ../../secrets/github-ssh-key.age;
    owner = userName;
    group = "users";
    mode = "0600";
  };
}

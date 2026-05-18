{ self, ... }: {
  flake.nixosModules.core = { ... }: {
    imports = [
      self.nixosModules.boot
      self.nixosModules.networking
      self.nixosModules.users
      self.nixosModules.locale
      self.nixosModules.nixConfig
      self.nixosModules.secrets
      self.nixosModules.hardware
      self.nixosModules.preservation
      self.nixosModules.security
    ];
  };
}

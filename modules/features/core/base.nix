{ self, ... }: {
  flake.nixosModules.base = { ... }: {
    imports = [
      self.nixosModules.system
      self.nixosModules.boot
      self.nixosModules.nixConfig
      self.nixosModules.networking
      self.nixosModules.security
      self.nixosModules.locale
      self.nixosModules.ssh
      self.nixosModules.users
      self.nixosModules.secrets
      self.nixosModules.shared
      self.nixosModules.shell
      self.nixosModules.services-base
      self.nixosModules.hardware-tuning
    ];
  };
}

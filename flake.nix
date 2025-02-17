{
  description = "A piece of rocket powered garment";

  inputs = { };

  outputs =
    { self, ... }:
    {
      homeManagerModules.jetbra =
        { ... }:
        {
          imports = [ ./modules ];
        };
    };
}

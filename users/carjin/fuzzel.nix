{
  programs.fuzzel.enable = true;
  programs.fuzzel.settings = ''
    [main]
    # Set the terminal command to use for applications that run in a terminal.
    # The default is to use the value of the TERMINAL environment variable.
    # terminal=alacritty -e

    # Specify the font to use. You can set the family, size, and other attributes.
    font=monospace:size=10

    # The prompt to display in the fuzzel window.
    prompt="
        > "

    # Number of lines to display.
    lines=15

    # Width of the fuzzel window in characters.
    width=40

    # Enable or disable icons.
    icons-enabled=yes

    [colors]
    # All colors are in hexadecimal RGBA format (RRGGBBAA).
    background=1e1e2eff
    text=dcdceeff
    selection=5a5a6eff
    border=3a3a3eff
    match=ff6e6eff

    [border]
    width=1
    radius=5		
    	 '';
}

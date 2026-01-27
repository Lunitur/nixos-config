{ ... }: {
  flake.modules.nixos.hosts.centaur.kmonad = { ... }:
  {
    services.kmonad.enable = true;

    services.kmonad.keyboards.main = {
      device = "/dev/input/by-path/pci-0000:02:00.0-usb-0:1:1.0-event-kbd";
      defcfg = {
        enable = true;
        fallthrough = true;
        compose.key = "lctl";
      };
      config = ''
        (defsrc
        	esc
        	grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        	tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        	caps a    s    d    f    g    h    j    k    l    ;    '    ret
        	lsft z    x    c    v    b    n    m    ,    .    /    rsft
        	lctl met  lalt           spc            ralt rctl lft  up   down rght
        )


        (deflayer base
        	esc
        	grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        	tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        	caps a    s    d    f    g    h    j    k    l    ;    '    ret
        	lsft z    x    c    v    b    n    m    ,    .    /    rsft
        	lctl met  lalt           spc            ralt @ltx lft  up   down rght
        )


        (defalias
        	;; layers
        	ltx (layer-toggle latex)       
        	lsf (layer-toggle latex-shifted) 
        	lgr (layer-toggle latex-greek)  
        	lgs (layer-toggle latex-greek-shifted)
        	
        	;; brackets
        	par #(\ l e f t ( \ r i g h t ) lft lft lft lft lft lft lft spc spc lft)
        	brk #(\ l e f t [ \ r i g h t ] lft lft lft lft lft lft lft spc spc lft)
        	sqg #(\ l e f t { \ r i g h t \ } lft lft lft lft lft lft lft lft spc spc lft)
        	ang #(\ l e f t \ l a n g l e \ r i g h t \ r a n g l e lft lft lft lft lft lft lft lft lft lft lft lft lft spc spc lft)
        	mbr #(\ l e f t | \ r i g h t | lft lft lft lft lft lft lft spc spc lft)

        	;; math mode
        	mmd #(\ ( \ ) lft lft spc spc lft)
        	eqm #(\ [ \ ] lft lft spc spc lft)


        	;; common building blocks
        	frc #(\ f r a c { } { } lft lft lft)
        	sum #(\ s u m \ l i m i t s \_ { } ^ { } lft lft lft lft)
         	int #(\ i n t \ l i m i t s \_ { } ^ { } lft lft lft lft)
        	sqrt #(\ s q r t  { } lft)
        	lim #(\ l i m \ l i m i t s { } lft)
        	
        	;; fonts and styles
        	mbb #(\ m a t h b b { } lft)
        	mbf #(\ m a t h b f { } lft)
        	mcal #(\ m a t h c a l { } lft)	

        	;; environments
        	eq #(\ b e g i n { e q u a t i o n } ret ret \ e n d { e q u a t i o n } up)
        	al #(\ b e g i n { a l i g n } ret ret \ e n d { a l i g n } up)

        	;; greek letters
        	alf #(\ a l p h a)
         	bet #(\ b e t a)
        	gam #(\ g a m m a)
        	del #(\ d e l t a)
        	eps #(\ v a r e p s i l o n)
        	the #(\ t h e t a)
        	zet #(\ z e t a)
        	lam #(\ l a m b d a)
        	mu #(\ m u)
        	phi #(\ v a r p h i)
        	chi #(\ c h i)
        	omg #(\ o m e g a)

        	Gam #(\ G a m m a)
        	Del #(\ D e l t a)
        	The #(\ T h e t a)
        	Lam #(\ L a m b d a)
        	Phi #(\ P h i)
        	Omg #(\ O m e g a)

        	;; other
        	ref #(~ \ r e f { } lft)
        	cite #(~ \ c i t e { } lft)
        )

        (deflayer latex
        	esc
        	grv  1    2    3    @mmd    @eqm    6    7    8    @par    @par    -    =    bspc
        	tab  @sqrt    w    @eq    @ref    t    y    u    @int    o    p    @brk    @brk    \
        	caps @al    @sum    d    @frc    @lgr    h    j    k    @lim    ;    '    ret
        	@lsf z    x    @cite    @mbf    @mbb    n    m    ,    .    /    @lsf
        	lctl met  lalt           spc            ralt _ lft  up   down rght
        )


        (deflayer latex-shifted
        	esc
        	grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        	tab  q    w    e    r    t    y    u    i    o    p    @sqg    @sqg    @mbr
        	caps a    s    d    f    @lgs    h    j    k    l    ;    '    ret
        	_ z    x    c    v    b    n    m    @ang    @ang    /    _
        	lctl met  lalt           spc            ralt _ lft  up   down rght
        )

        (deflayer latex-greek
        	esc
        	grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        	tab  q    @omg    @eps    r    @the    y    u    i    @omg    @phi    [    ]    \
        	caps @alf    s    @del    @phi    _    @chi    j    k    @lam    ;    '    ret
        	@lgs @zet    @chi    @gam    v    @bet    n    @mu    ,    .    /    @lgs
        	lctl met  lalt           spc            ralt _ lft  up   down rght
        )


        (deflayer latex-greek-shifted
        	esc
        	grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        	tab  q    @Omg    e    r    @The    y    u    i    @Omg    @Phi    [    ]    \
        	caps a    s    @Del    @Phi    _    h    j    k    @Lam    ;    '    ret
        	_ z    x    @Gam    v    b    n    m    ,    .    /    _
        	lctl met  lalt           spc            ralt _ lft  up   down rght
        )
      '';
    };

  };
}

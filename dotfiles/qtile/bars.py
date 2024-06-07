import os
from itertools import cycle as cycle
from libqtile import bar, widget, qtile

from defaults import myTerm, home
from colorschemes import colors

colorcycle = cycle([colors.get('laven'), colors.get('lyg'), colors.get('lblue'), colors.get('lye'), colors.get('lpnk')])

from extras.widgets import _Net

color_cycle = cycle([
        colors.get('laven'),
        colors.get('lyg'),
        colors.get('lblue'),
        colors.get('lye'),
        colors.get('plum'),
        colors.get('pist'),
        colors.get('lpnk')
    ])

main_background = colors.get('lblack')
main_foreground = colors.get('laven')

theme_defaults = dict(
            font='Hack Nerd Font Bold',
            fontsize=14,
            icon_size=14,
            padding=10,
            background=main_background,
        )

icons = {
        'cpu': '\uf4bc',
        'ram': '\uefc5',
        'calendar': '\ueab0',
        'clock': '\uf017',
        'layout': '\uebeb',
        'connection': '\udb80\udc02',
        'arrow_down': '\uf175',
        'arrow_up': '\uf176',
        'clipboard': '\uf07f',
        'update': '\udb81\udeb0',
        'checkmark': '\uf4b2',
        'search': '\uf4b1',
    }

utf16_patch = lambda _str: _str.encode('utf-16', 'surrogatepass').decode('utf-16')
icons = {k: utf16_patch(v) if len(v) > 1 else v for k, v in icons.items()}

w_groupbox = lambda: widget.GroupBox(
            foreground=colors.get('laven'),
            background=main_background,
            font='Hack Nerd Font Bold',
            fontsize=14,

            margin=3,
            borderwidth=0,
            padding=5,
            active=colors.get('lyg'),
            inactive=colors.get('laven'),
            rounded=False,
            highlight_method='block',
            urgent_alert_method='block',
            urgent_border=colors.get('plum'),
            disable_drag=True,
        )

w_spacer = lambda: widget.Spacer(
            length=bar.STRETCH,
            background=main_background,
        )

w_window_name = lambda: widget.WindowName(foreground=colors.get('white'), max_chars=30, **theme_defaults)

w_sep = lambda linewidth: widget.Sep(
            linewidth=linewidth,
            padding=0,
            foreground=main_background,
            background=main_background
        )

w_current_layout = lambda: widget.CurrentLayout(
            fmt=icons.get('layout', 'L') + ' {}',
            foreground=next(color_cycle),
            **theme_defaults,
        )

w_updates = lambda: widget.CheckUpdates(
            display_format=icons.get('update', 'UPD') + '{updates}',
            custom_command='paru -Qu',
            update_interval=3600,
            no_update_string=icons.get('checkmark', ':)'),
            initial_text=icons.get('search', '...'),
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e garuda-update')},
            **theme_defaults,
        )

w_clipboard = lambda: widget.Clipboard(
            fmt=icons.get('clipboard', 'clip') + ' {}',
            max_chars=10,
            timeout=None,
            foreground=next(color_cycle),
            **theme_defaults,
        )

w_cpu = lambda: widget.CPU(
            format=icons.get('cpu', 'CPU') + ' {load_percent}%',
            update_interval=3,
            foreground=next(color_cycle),
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e htop')},
            **theme_defaults,
        )

w_ram = lambda: widget.Memory(
            format=icons.get('ram', 'RAM') + ' {MemUsed:.1f}/{MemTotal:.1f} GiB',
            update_interval=3,
            measure_mem='G',
            foreground=next(color_cycle),
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e htop')},
            **theme_defaults,
        )

w_net = lambda: _Net(
            format=(
                    icons.get('connection') +
                    ' {down:>3.0f}{down_suffix}' +
                    icons.get('arrow_down', 'D') +
                    ' {up:>3.0f}{up_suffix}' +
                    icons.get('arrow_up', 'U')
                ),
            foreground=next(color_cycle),
            update_interval=1,
            **theme_defaults,
        )

w_clock = lambda: widget.Clock(
            format=icons.get('calendar', 'CAL') + ' %a %d %b ' + icons.get('clock', 'CLOCK') + ' %I:%M %p',
            foreground=next(color_cycle),
            **theme_defaults,
        )

w_tray = lambda: widget.Systray(**theme_defaults) if (qtile.core.name == "x11") else widget.StatusNotifier(**theme_defaults)

w_menu = lambda: widget.Image(
            filename="~/.config/qtile/icons/qtilelogo2.png",
            iconsize=9,
            background=colors.get('lblack'),
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn('jgmenu_run')}
            )

w_tasklist = lambda: widget.TaskList(
    margin = 0,
    padding_y = 5,
    **theme_defaults)

def init_widgets_screen1():
    widgets_list_screen1 = [
            w_sep(5),
            w_menu(),
            w_groupbox(),
      #      w_window_name(),
            w_tasklist(),
      #      w_spacer(),
            w_current_layout(),
           # w_updates(),
           # w_clipboard(),
            w_cpu(),
            w_ram(),
            w_net(),
            w_clock(),
            w_tray(),
            w_sep(5),
        ]
    return widgets_list_screen1


def init_widgets_screen2():
    widgets_list_screen2 = [

        w_sep(5),              #
        w_menu(),
        w_groupbox(),
        w_tasklist(),
        w_spacer(),
        w_clock(),
        w_sep(5)
    ]

    return widgets_list_screen2


main_bar = bar.Bar(widgets=init_widgets_screen1(), size=25,
                   opacity=0.85, background="000000")

main_bar2 = bar.Bar(widgets=init_widgets_screen2(), size=25,
                    opacity=0.85, background="000000")

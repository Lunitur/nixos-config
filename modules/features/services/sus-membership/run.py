import asyncio
import runpy

# Maubot 0.6 expects an existing event loop; Python 3.14 no longer creates one implicitly.
asyncio.set_event_loop(asyncio.new_event_loop())
runpy.run_module("maubot.standalone", run_name="__main__")

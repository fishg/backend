import sentry_sdk

from app.utils.ip import get_external_ip
from app.core import config


if config.ENABLE_SENTRY:
    sentry_sdk.init(
        release=f"{config.BACKEND_VERSION}",
        environment=f"{config.ENVIRONMENT}",
        dsn="https://f320001640444ef1ab2bc739065c4ad6@sentry.660161.xyz/6112405",
        traces_sample_rate=1.0,
    )
    sentry_sdk.set_tag("panel.ip", get_external_ip())


from .config import huey

from .ansible import *
from .app import *
from .artifacts import *
from .clean import *
from .iptables import *
from .server import *
from .tc import *
from .traffic import *

ansible_hosts_runner()
servers_runner(prepare_services=True, sync_scripts=True, init_iptables=True)

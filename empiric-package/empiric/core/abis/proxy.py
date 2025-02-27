PROXY_ABI = [
    {
        "data": [{"name": "implementation", "type": "felt"}],
        "keys": [],
        "name": "Upgraded",
        "type": "event",
    },
    {
        "data": [
            {"name": "previousAdminAddress", "type": "felt"},
            {"name": "newAdminAddress", "type": "felt"},
        ],
        "keys": [],
        "name": "AdminAddressChanged",
        "type": "event",
    },
    {
        "inputs": [
            {"name": "implementation_hash", "type": "felt"},
            {"name": "selector", "type": "felt"},
            {"name": "calldata_len", "type": "felt"},
            {"name": "calldata", "type": "felt*"},
        ],
        "name": "constructor",
        "outputs": [],
        "type": "constructor",
    },
    {
        "inputs": [
            {"name": "selector", "type": "felt"},
            {"name": "calldata_size", "type": "felt"},
            {"name": "calldata", "type": "felt*"},
        ],
        "name": "__default__",
        "outputs": [
            {"name": "retdata_size", "type": "felt"},
            {"name": "retdata", "type": "felt*"},
        ],
        "type": "function",
    },
    {
        "inputs": [
            {"name": "selector", "type": "felt"},
            {"name": "calldata_size", "type": "felt"},
            {"name": "calldata", "type": "felt*"},
        ],
        "name": "__l1_default__",
        "outputs": [],
        "type": "l1_handler",
    },
]

RPKI INVALID routes tagging
***************************

Mostly to test hooks and include files in a scenario where a custom configuration allows to propagate RPKI INVALID routes to some selected clients and to tag them with locally significant BGP communities.

Hooks used:

- ``announce_rpki_invalid_to_client``, implemented in the ``header[4|6]`` include files and used to discriminate which clients should receive INVALIDs;
- ``post_announce_to_client``, implemented in the ``header`` include file and used to convert RFC8097 extended communities into locally significant ones.

- RPKI ROAs:

    == ==============  ====  ======
    ID Prefix          Max   ASN
    == ==============  ====  ======
    1  2.0.8.0/24            101
    2  2.0.9.0/24            102
    3  2.0.128.0/20    23    101
    4  3.0.8.0/24            103
    5  3.0.9.0/24            102
    6  3.0.128.0/20    23    103
    == ==============  ====  ======

    == ================  ====  ======
    ID Prefix            Max   ASN
    == ================  ====  ======
    1  3002:0:8::/48           101
    2  3002:0:9::/48           102
    3  3002:0:8000::/33  34    101
    4  3003:0:8::/48           103
    5  3003:0:9::/48           102
    6  3003:0:8000::/33  34    103
    == ================  ====  ======

- Locally significant communities:

  ==============  =============
  Validity state  BGP community
  ==============  =============
  VALID           64512:1
  INVALID         64512:2
  UNKNOWN         64512:3
  ==============  =============

- AS1, receives only

  Configured to receive INVALID routes using the hook ``announce_rpki_invalid_to_client``, implemented in the local ``header[4|6]`` file.

- AS2:

  Configured with ``reject_invalid`` False.

  Annouced prefixes:

  ====================  ================   ========== ==================================================================================
  Prefix ID             Prefix             AS_PATH    Expected result and BGP community received by AS1
  ====================  ================   ========== ==================================================================================
  AS2_valid1            2.0.8.0/24,        2 101      roa check ok, 64512:1 on AS1 and AS4
                        3002:0:8::/48
  AS2_valid2            2.0.128.0/21,      2 101      roa check ok, 64512:1 on AS1 and AS4
                        3002:0:8000::/34
  AS2_invalid1          2.0.9.0/24,        2          roa check fail (roa n. 2, bad origin ASN), 64512:2 on AS1 only
                        3002:0:9::/48
  AS2_badlen            2.0.128.0/24,      2 101      roa check fail (roa n. 3, bad length), 64512:2 on AS1 only
                        3002:0:8000::/35
  AS2_unknown1          2.2.0.0/16         2          roa check unknown, 64512:3 on AS1 and AS4
                        3002:3002::/32
  ====================  ================   ========== ==================================================================================

- AS3:

  Configured with ``reject_invalid`` True.

  Annouced prefixes:

  ====================  ================   ========== ==================================================================================
  Prefix ID             Prefix             AS_PATH    Expected result and BGP community received by AS1
  ====================  ================   ========== ==================================================================================
  AS3_valid1            3.0.8.0/24,        3 103      roa check ok, 64512:1 on AS1 and AS4
                        3003:0:8::/48
  AS3_valid2            3.0.128.0/21,      3 103      roa check ok, 64512:1 on AS1 and AS4
                        3003:0:8000::/34
  AS3_invalid1          3.0.9.0/24,        3          roa check fail (roa n. 2, bad origin ASN), rejected
                        3003:0:9::/48
  AS3_badlen            3.0.128.0/24,      3 103      roa check fail (roa n. 3, bad length), rejected
                        3003:0:8000::/35
  AS3_unknown1          3.2.0.0/16         2          roa check unknown, 64512:3 on AS1 and AS4
                        3003:3003::/32
  ====================  ================   ========== ==================================================================================

- AS4, receives only with no particular configuration.

from enum import Enum


class SessionInstance:
    __instance = None
    connection_id = -1
    server_config_id = ""
    source_address_token = ""
    public_value = None # object
    public_values_bytes = ""
    private_value = None
    chlo = ""
    scfg = ""
    cert = "308203B43082029CA003020102020101300D06092A864886F70D01010B0500301E311C301A06035504030C13515549432053657276657220526F6F74204341301E170D3138303631383132343835365A170D3139303631383132343835365A3064310B30090603550406130255533113301106035504080C0A43616C69666F726E69613116301406035504070C0D4D6F756E7461696E205669657731143012060355040A0C0B51554943205365727665723112301006035504030C093132372E302E302E3130820122300D06092A864886F70D01010105000382010F003082010A0282010100AC8B7A6986CB04B83BB6F6872B7635F9AA8DE89216A92B0C645FBCBFDF72F79E4B573198EB08331BA1E754E1B662B13A077E0A92D5FF1E8A8F79763F9C12DC4F58D4A35A61C0A8E49597DE614929276B41ECE9AF814A74B30BB9CF14143F4FC6B21A4511E5A6ACA4D174220E372FE043A105C0CBCE6E749D71265770628DDD2F8FD146AC5705DCEB3A73A1873BA9AFE0D5E1D348A123CA508B8ED816E896118AFF0C609545B61DACBBF0D656FCE68D8B7235907F30049148CAF5A39A2F4CB39F6DD79876A83E42262817963A95ED780C966F267136612980EE14FF5DD62CAA1140E6CFBB15264ACEF0F88FE6FE91182235FC8C73012695143219E6D1D48131DB0203010001A381B63081B3300C0603551D130101FF04023000301D0603551D0E041604143ECD5BB55DACCAD991FAECB9ABE7427BE5730CFB301F0603551D2304183016801441D602AE70B88354D750609956C2944C9DFFEAEB301D0603551D250416301406082B0601050507030106082B0601050507030230440603551D11043D303B820F7777772E6578616D706C652E6F726782106D61696C2E6578616D706C652E6F726782106D61696C2E6578616D706C652E636F6D87047F000001300D06092A864886F70D01010B050003820101000B7FDD3124F8D566FC352E04C88CEBF18FAD45EE4742A88D24703F35591326BF8695AFC276123F75AA4A5CCE6CAF442973CAED49E1BEC9516DCBE9D6E317E4BCD50C13C0B6EA6B20A0DFA3EC2BB129B35CC939912613CB5C74B22FF912F50F1D07B12027A6F5D74AC9D07579CB538E38C6613F0F5D023AA3C81D042002AF1F9BABC3FC2AFFC2D0567ACEF114A348C8249DC9BAA294F6088D83D8B33A92D1E6A9F611E167436732E63D89CF2D8476F0E80169D40F6329369C93EBF50B9E5E0B31D2175F366CA66BF6711713BACC118B3D1B786403E408884A3F3149C53B7CD62627CA3B3384AFC73F550F3133194B0D7D23F1CCEB971BF105865AEEBC15581DEA"
    # cert = "308203b43082029ca003020102020101300d06092a864886f70d01010b0500301e311c301a06035504030c13515549432053657276657220526f6f74204341301e170d3138303332323134323231325a170d3139303332323134323231325a3064310b30090603550406130255533113301106035504080c0a43616c69666f726e69613116301406035504070c0d4d6f756e7461696e205669657731143012060355040a0c0b51554943205365727665723112301006035504030c093132372e302e302e3130820122300d06092a864886f70d01010105000382010f003082010a0282010100c736b59daa3946856ad4c435600872cc1bda9d080d903d26c9cdcc640ceac3d0149df3de7164d63ae6cc0acefe478927a618f801bb3491904f1bddaa117e04889ed569c4f91b25ffea519e44d52dd5adc2e3c82219c69920cdabac9614b5e050224d4bdd76a8a5dfa38ded84e3bb3be440891f44f9e8b2eed6508a66d5b257c16709832f78d23371c3baca1d77fbc9b3226be2064b67b200fdb5ddc49995b13a3ae889812ed784203a5d11d72fdabbea42d9a658f6ed7799ed114dd833196ff1e52dd89191f0e462e957f4d088a4be5848a511be5712f36bd348ab5fe30c7342112b9ea70da9139ba4a80a8cf5f9e380255521a2b08bab5d2e8bb262bcf671fd0203010001a381b63081b3300c0603551d130101ff04023000301d0603551d0e041604142b02b2222d9ef7099633496d64cac59b3aff99f7301f0603551d23041830168014259334b660242a4a3e5b1bf95bfed3c3e0d70c4c301d0603551d250416301406082b0601050507030106082b0601050507030230440603551d11043d303b820f7777772e6578616d706c652e6f726782106d61696c2e6578616d706c652e6f726782106d61696c2e6578616d706c652e636f6d87047f000001300d06092a864886f70d01010b05000382010100436ccdd416efc4eda50796f61d0100187aca65eeb04f2cd84191c92d69b8b6e2f3187001e628a045505db576e978eae31b625d51d62863a1ed783b22639553b6213c476e67fb5fea20522fd7302e32124c04eaf5966740d5d9e145ee6a5b16f8f0c5ba0ae0de2edf75a1a653547fcfcf7d5d376d49efa87979fd06d969666c447f6676db9d4a0f9158e47eb88e3da13fbf3ad579863dc2963bed437806ec78ec0c3f1807f40f4984abc00ce2b747226579df9b3af66e03f1c4b9095bd624d38e0641fd1fe728a99000f7622755179b0b7cac6de25a4e293b663584334303294f6655aea4c181c2a07283515b9b87a4adeacae67982eb681f4da51574d74f27bc"
    # cert = "308203B130820299A003020102020101300D06092A864886F70D01010B0500301E311C301A06035504030C13515549432053657276657220526F6F74204341301E170D3138303631383131333635325A170D3139303631383131333635325A3064310B30090603550406130255533113301106035504080C0A43616C69666F726E69613116301406035504070C0D4D6F756E7461696E205669657731143012060355040A0C0B51554943205365727665723112301006035504030C093132372E302E302E3130820122300D06092A864886F70D01010105000382010F003082010A0282010100E721A45922B4A959F3031DAB012808C15F1A7AE79D2011603901312830B7E07C04EC6BA4B59EFD8AC02194AC55C5B307865B4E02ACECD196E65659AE78BE6871C830C65CF414DAE6B052570339AF3155009A17D86C970BBF394DAB904D682E4F5973CD330325D6CD1DCD7CE53E8A72882D8A962AABF295F7842ECAB96A107E67E24CB043D6B0A673B4809927FC39660DFABC38517A8A4CE7F4470BA45AD14EA4777E6747C1D86D63FA4BB9C9C560198DD281525EE385031D07ADBD3C5F73410D151032E2BD2D7E91A9C71C96765E6AF5120BE01F895E74917262E80A1F82BEBE8D04B1BCBACC17C1E659CD1567A4EB7D52EE460B6F9F00E015D278A7132B99E10203010001A381B33081B0300C0603551D130101FF04023000301D0603551D0E0416041451D9BEC55C258F2745B405EB53326DDA4C5AFE37301F0603551D230418301680144B163C9B75F4EDDD75939CB10864DFBBD7CB4EAE301D0603551D250416301406082B0601050507030106082B0601050507030230410603551D11043A3038820F7777772E6578616D706C652E6F7267820D7777772E65787472612E6F726782106D61696C2E6578616D706C652E636F6D87047F000001300D06092A864886F70D01010B050003820101009E1506021964176CA5A7C3AA012145F7123240A75DC9AF0AF09EBF6346411B282124ABC7486C9436C6840844EA5EFCB7E3BE87826ABBD30DFD4F79E08D0F3376EE195EC6DD3634CF03D551B213746EF5A708EB743EEB1AF0833D3694D5177E6481B91850362DEA98BB78153968C51450AEE76A8E309291881810285DC3087C17AF67A0259C15432A3D1B1065A1F4C8DAEE01C35918DECF77CC2CC8F3375FDAC7FEC1C3E892288347481204394B84C859C44095520E3ED80890E214A4E86956368E89496A90F6FDACB0F06FE48B35C16E41C8155AF7C46A14B3ACCB0FD98C561C9883BF36E7E001584BD25C5E9F730A8EE2159E69AE03E04938B4DC1DF0972BE0"
    server_nonce = "efc36b712c31d0adff9aa9f11cadc41ecc82eaa6a77edbb50539a6e614fb969da8b0d74d1a0a1026850e21412b116f9c21bcb7db"
    keys = {}
    peer_public_value = ""
    div_nonce = ""
    message_authentication_hash = ""
    associated_data = ""
    packet_number = ""
    largest_observed_packet_number = -1
    shlo_received = False
    nr_ack_send = 0
    connection_id_as_number = -1
    destination_ip = "192.168.1.69"  # Home connectiopns
    # destination_ip = "192.168.43.228"   # hotspot connections
    zero_rtt = False
    last_received_rej = ""  # We are only interested in the last REJ for the initial keys.
    last_received_shlo = ""
    app_keys = {'type': None, 'mah': "", 'key': {}}
    first_packet_of_new_command = False
    currently_sending_zero_rtt = False  # If it is set to True, then we do not need to store the REJ otherwise it will not work.

    @staticmethod
    def get_instance():
        if SessionInstance.__instance is None:
            return SessionInstance()
        else:
            return SessionInstance.__instance

    def __init__(self):
        if SessionInstance.__instance is not None:
            raise Exception("Singleton bla")
        else:
            self.server_config_id = "-1"
            self.source_address_token = "-1"
            SessionInstance.__instance = self


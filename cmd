	utils.Fatalf("could not generate key: %v", err)
		}
		if err = crypto.SaveECDSA(*genKey, nodeKey); err != nil {
			utils.Fatalf("%v", err)
		}
		if !*writeAddr {
			return
		}
	case *nodeKeyFile == "" && *nodeKeyHex == "":
		utils.Fatalf("Use -nodekey or -nodekeyhex to specify a private key")
	case *nodeKeyFile != "" && *nodeKeyHex != "":
		utils.Fatalf("Options -nodekey and -nodekeyhex are mutually exclusive")
	case *nodeKeyFile != "":
		if nodeKey, err = crypto.LoadECDSA(*nodeKeyFile); err != nil {
			utils.Fatalf("-nodekey: %v", err)
		}
	case *nodeKeyHex != "":
		if nodeKey, err = crypto.HexToECDSA(*nodeKeyHex); err != nil {
			utils.Fatalf("-nodekeyhex: %v", err)
		}
	}
	if *writeAddr {
		fmt.Printf("%x\n", crypto.FromECDSAPub(&nodeKey.PublicKey)[1:])
		os.Exit(0)
	}
	var restrictList *netutil.Netlist
	if *netrestrict != "" {
		restrictList, err = netutil.ParseNetlist(*netrestrict)
		if err != nil {
			utils.Fatalf("-netrestrict: %v", err)
		}
	}
	addr, err := net.ResolveUDPAddr("udp", *listenAddr)
	if err != nil {
		utils.Fatalf("-ResolveUDPAddr: %v", err)
	}
	conn, err := net.ListenUDP("udp", addr)
	if err != nil {
		utils.Fatalf("-ListenUDP: %v", err)
	}
	defer conn.Close()

	realaddr := conn.LocalAddr().(*net.UDPAddr)
	if natm != nil {

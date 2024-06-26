package main

import (
	"context"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/feynmaz/Real-Estate-Dapp/internal/config"
	"github.com/feynmaz/Real-Estate-Dapp/internal/logger"
	"github.com/spf13/pflag"
)

func main() {
	log := logger.New()
	configPath := pflag.StringP("config", "c", "", "path to config file")
	pflag.Parse()

	cfg, err := config.Load(*configPath)
	if err != nil {
		log.Fatal().Err(err).Msg("failed to load config")
	}

	client, err := ethclient.Dial(cfg.EthClient.Url)
	if err != nil {
		log.Fatal().Err(err).Msg("failed to dial eth client")
	}

	// Get the balance of an account
	account := common.HexToAddress(cfg.Web3Account.Address)
	balance, err := client.BalanceAt(context.Background(), account, nil)
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to get balance of %s", cfg.Web3Account.Address)
	}

	log.Info().Msgf("Account %s balance: %d\n", cfg.Web3Account.Address, balance)

	// Get the latest known block
	block, err := client.BlockByNumber(context.Background(), nil)
	if err != nil {
		log.Fatal().Err(err).Msg("failed to get latest block")
	}

	log.Info().Msgf("Latest block: %d\n", block.Number().Uint64())
}

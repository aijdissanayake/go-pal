package ethapi

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"math/big"
	"strings"

	"github.com/policypalnet/go-ppn/common"
	"github.com/policypalnet/go-ppn/common/hexutil"
	"github.com/policypalnet/go-ppn/core/types"
	"github.com/policypalnet/go-ppn/log"
	"github.com/policypalnet/go-ppn/rlp"
)

var (
	ErrSupernodeNotExist    = errors.New("Supernode address must be existed.")
	ErrRequestInvalidLength = errors.New("Length of requests are invalid.")
)

type PublicGatewayAPI struct {
	b         Backend
	nonceLock *AddrLocker
}

type TxArgs struct {
	From     common.Address  `json:"from"`
	To       *common.Address `json:"to"`
	Gas      *hexutil.Uint64 `json:"gas"`
	GasPrice *hexutil.Big    `json:"gasPrice"`
	Value    *hexutil.Big    `json:"value"`
	Nonce    *hexutil.Uint64 `json:"nonce"`
	// We accept "data" and "input" for backwards-compatibility reasons. "input" is the
	// newer name and should be preferred by clients.
	Data  *hexutil.Bytes `json:"data"`
	Input *hexutil.Bytes `json:"input"`
}

// SendTxArgs represents the arguments to sumbit a new transaction into the transaction pool.
type SendTxsArgs struct {
	SNAddress    common.Address `json:"snAddress"`
	Transactions []TxArgs       `json:"transactions"`
}

func NewPublicGatewayAPI(b Backend, nonceLock *AddrLocker) *PublicGatewayAPI {
	return &PublicGatewayAPI{
		b:         b,
		nonceLock: nonceLock,
	}
}

// setDefaults is a helper function that fills in default values for unspecified tx fields.
func (tx *TxArgs) setDefaults(ctx context.Context, b Backend) error {
	if tx.Gas == nil {
		tx.Gas = new(hexutil.Uint64)
		*(*uint64)(tx.Gas) = 90000
	}
	if tx.GasPrice == nil {
		price, err := b.SuggestPrice(ctx)
		if err != nil {
			return err
		}
		tx.GasPrice = (*hexutil.Big)(price)
	}
	if tx.Value == nil {
		tx.Value = new(hexutil.Big)
	}
	if tx.Nonce == nil {
		nonce, err := b.GetPoolNonce(ctx, tx.From)
		if err != nil {
			return err
		}
		tx.Nonce = (*hexutil.Uint64)(&nonce)
	}
	if tx.Data != nil && tx.Input != nil && !bytes.Equal(*tx.Data, *tx.Input) {
		return errors.New(fmt.Sprintf("Transaction from: %v %s", tx.From, ` Both "data" and "input" are set and not equal. Please use "input" to pass transaction call data.`))
	}
	if tx.To == nil {
		// Contract creation
		var input []byte
		if tx.Data != nil {
			input = *tx.Data
		} else if tx.Input != nil {
			input = *tx.Input
		}
		if len(input) == 0 {
			return errors.New(fmt.Sprintf("Transaction from: %v %s", tx.From, `contract creation without any data provided`))
		}
	}
	return nil
}

func (tx *TxArgs) toTransaction() *types.Transaction {
	var input []byte
	if tx.Data != nil {
		input = *tx.Data
	} else if tx.Input != nil {
		input = *tx.Input
	}
	if tx.To == nil {
		return types.NewContractCreation(uint64(*tx.Nonce), (*big.Int)(tx.Value), uint64(*tx.Gas), (*big.Int)(tx.GasPrice), input)
	}

	return types.NewTransaction(uint64(*tx.Nonce), *tx.To, (*big.Int)(tx.Value), uint64(*tx.Gas), (*big.Int)(tx.GasPrice), input)
}

func (s *PublicGatewayAPI) SendRawTransactions(ctx context.Context, snAddresses []common.Address, encodedTxs []hexutil.Bytes) ([]common.Hash, error) {
	if len(snAddresses) != len(encodedTxs) {
		return make([]common.Hash, 0), ErrRequestInvalidLength
	}
	var txsHash []common.Hash
	errMap := make(map[string]string, 0)
	for index, encodedTx := range encodedTxs {
		tx := new(types.Transaction)
		if err := rlp.DecodeBytes(encodedTx, tx); err != nil {
			errMap[tx.Hash().Hex()] = err.Error()
			continue
		}
		tx.SNAddress = &snAddresses[index]
		newTX, err := submitTransaction(ctx, s.b, tx)
		if err != nil {
			errMap[tx.Hash().Hex()] = err.Error()
			continue
		}
		txsHash = append(txsHash, newTX)
	}
	if len(errMap) != 0 {
		jsErr, err := json.Marshal(errMap)
		if err != nil {
			return txsHash, err
		}
		return txsHash, errors.New(string(jsErr))
	}
	return txsHash, nil
}

func (s *PublicGatewayAPI) Rewards(ctx context.Context) (map[string]uint, error) {
	res := make(map[string]uint, 0)
	masternodes, err := ioutil.ReadFile("./masternodeReward.txt")
	if err != nil {
		log.Error(err.Error())
	}
	supernodes, err := ioutil.ReadFile("./supernodeReward.txt")
	if err != nil {
		log.Error(err.Error())
	}
	addresses := strings.Split(string(masternodes), "\n")
	addresses = append(addresses, strings.Split(string(supernodes), "\n")...)
	for _, address := range addresses {
		fmt.Println(address)
		res[address]++
	}
	delete(res, "")
	delete(res, "0x0000000000000000000000000000000000000000")

	return res, nil
}

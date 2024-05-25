package logger

import (
	"os"
	"time"

	"github.com/rs/zerolog"
)

type Logger struct {
	zerolog.Logger
}

func New() Logger {
	output := zerolog.ConsoleWriter{
		Out:        os.Stdout,
		TimeFormat: time.RFC3339,
		NoColor:    false,
	}

	logger := zerolog.New(output).With().Timestamp().Caller().Logger()
	return Logger{logger}
}

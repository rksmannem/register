package config

import "time"

type API struct {
	Address         string        `env:"API_ADDRESS" envDefault:"0.0.0.0"`
	Port            string        `env:"API_PORT" envDefault:"8080"`
	ShutdownTimeout time.Duration `env:"API_SHUTDOWN_TIMEOUT" envDefault:"60s"`
}

type Config struct {
	ServiceName string `env:"SERVICE_NAME" envDefault:"register-service"`
	API         API
}

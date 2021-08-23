package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/rksmannem/register/config"
	"github.com/rksmannem/register/version"

	"github.com/caarlos0/env/v6"
	"github.com/rksmannem/register/internal/routers"
	"go.uber.org/zap"
)

// How to try it: PORT=8000 go run main.go
func main() {
	log.Printf(
		"Starting the service...\ncommit: %s, build time: %s, release: %s",
		version.Commit, version.BuildTime, version.Release,
	)

	/*port := os.Getenv("PORT")
	if port == "" {
		log.Fatal("port is not set.")
	}*/
	cfg := config.Config{}
	if err := env.Parse(&cfg); err != nil {
		log.Fatalf("fail to parse configuration, error: %v", err)
	}

	z, err := zap.Config{
		Level:            zap.NewAtomicLevelAt(zap.DebugLevel),
		Development:      false,
		Encoding:         "json",
		EncoderConfig:    zap.NewProductionEncoderConfig(),
		OutputPaths:      []string{"stderr"},
		ErrorOutputPaths: []string{"stderr"},
	}.Build(zap.AddCaller(), zap.AddCallerSkip(1))
	if err != nil {
		log.Fatalf("fail to initialize logger")
	}
	defer z.Sync()

	cl := z.With(
		zap.String("version.Release", version.Release),
		zap.String("service.Name", cfg.ServiceName),
		zap.String("api_address", cfg.API.Address),
		zap.String("api_port", cfg.API.Port),
	)
	r := routers.Router(cl, version.BuildTime, version.Commit, version.Release)

	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM)

	srv := &http.Server{
		Addr:    cfg.API.Address + ":" + cfg.API.Port,
		Handler: r,
	}

	// this channel is for graceful shutdown:
	// if we receive an error, we can send it here to notify the server to be stopped
	shutdown := make(chan struct{}, 1)
	go func() {
		err := srv.ListenAndServe()
		if err != nil {
			shutdown <- struct{}{}
			log.Printf("%v", err)
			cl.Error("error listening", zap.Error(err))
		}
	}()
	cl.Info("service is running")

	select {
	case killSignal := <-interrupt:
		switch killSignal {
		case os.Interrupt:
			log.Print("Got SIGINT...")
		case syscall.SIGTERM:
			log.Print("Got SIGTERM...")
		}
	case <-shutdown:
		log.Printf("Got an error...")
	}

	log.Print("The service is shutting down...")
	srv.Shutdown(context.Background())
	log.Print("Done")
}

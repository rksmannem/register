package routers

import (
	"github.com/gorilla/mux"
	"github.com/rksmannem/register/internal/handlers"
	"go.uber.org/zap"
)

// Router register necessary routes and returns an instance of a router.
func Router(lgr *zap.Logger, buildTime, commit, release string) *mux.Router {

	r := mux.NewRouter()
	r.HandleFunc("/home", handlers.Home(lgr, buildTime, commit, release)).Methods("GET")
	return r
}

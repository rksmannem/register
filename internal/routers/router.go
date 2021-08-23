package routers

import (
	"github.com/gorilla/mux"
	"github.com/rksmannem/register/internal/handlers"
)

// Router register necessary routes and returns an instance of a router.
func Router(buildTime, commit, release string) *mux.Router {

	r := mux.NewRouter()
	r.HandleFunc("/home", handlers.Home(buildTime, commit, release)).Methods("GET")
	return r
}

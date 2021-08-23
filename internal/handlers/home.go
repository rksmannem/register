package handlers

import (
	"encoding/json"
	"go.uber.org/zap"
	"log"
	"net/http"
)

// Home returns a simple HTTP handler function which writes a response.
func Home(lgr *zap.Logger, buildTime, commit, release string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		info := struct {
			BuildTime string `json:"buildTime"`
			Commit    string `json:"commit"`
			Release   string `json:"release"`
		}{
			buildTime, commit, release,
		}

		lgr.Info("Home handler")
		body, err := json.Marshal(info)
		if err != nil {
			log.Printf("Could not encode info data: %v", err)
			http.Error(w, http.StatusText(http.StatusServiceUnavailable), http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Write(body)
	}
}

package main

import (
	"net/http/httptest"
	"testing"
)

func TestHealthEndpoints(t *testing.T) {
	ready := true
	handler := newHandler(&ready)
	for _, path := range []string{"/healthz", "/readyz"} {
		req := httptest.NewRequest("GET", path, nil)
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, req)
		if rec.Code != 200 { t.Fatalf("%s returned %d", path, rec.Code) }
	}
}

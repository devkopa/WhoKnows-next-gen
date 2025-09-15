"use client";

import { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";

export default function SearchPage() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    const q = searchParams.get("q") || "";
    setQuery(q);

    if (!q) {
      setResults([]);
      return;
    }

    async function fetchResults() {
      setLoading(true);
      setError(null);
      
      try {
        const res = await fetch(`/api/search?q=${encodeURIComponent(q)}&language=en`);
        
        if (!res.ok) {
          throw new Error(`HTTP error! status: ${res.status}`);
        }
        
        const data = await res.json();
        
        
        let resultsArray = [];
        
        if (Array.isArray(data.data)) {
          resultsArray = data.data;
        } else {
          console.warn("Unexpected data structure:", data);
          resultsArray = [];
        }
        
        
        setResults(resultsArray);
      } catch (err) {
        console.error("Fetch error:", err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchResults();
  }, [searchParams]);

  function handleSearch() {
    if (!query.trim()) return;
    const params = new URLSearchParams();
    params.set("q", query.trim());
    params.set("language", "en");
    router.push(`/search?${params.toString()}`);
  }

  function handleKeyPress(e) {
    if (e.key === "Enter") handleSearch();
  }

  return (
    <div className="p-6 max-w-2xl mx-auto">
      <div className="flex gap-2 mb-6">
        <input
          autoFocus
          placeholder="Search..."
          className="flex-1 border rounded px-3 py-2"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyPress={handleKeyPress}
        />
        <button
          onClick={handleSearch}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          disabled={loading}
        >
          {loading ? "Searching..." : "Search"}
        </button>
      </div>

      <div id="results">
        {loading && <p className="text-gray-600">Loading...</p>}
        
        {error && (
          <p className="text-red-600">Error: {error}</p>
        )}
        
        {!loading && !error && results.length > 0 ? (
          <>
            <p className="text-sm text-gray-600 mb-4">
              Found {results.length} results
            </p>
            {results.map((result, idx) => {

              
              return (
                <div key={`result-${idx}-${result.url || result.link || idx}`} className="mb-4 p-3 border-b">
                  <h2>
                    <a
                      href={result.url || "#"}
                      className="text-lg font-semibold text-blue-600 hover:underline"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      {result.title || "No title"}
                    </a>
                  </h2>
                  <p className="text-gray-700 mt-1">
                    {(result.content || "No description").substring(0,150)}
                    {(result.content || "").length > 150 && "..."}
                  </p>
                  
                </div>
              );
            })}
          </>
        ) : (
          !loading && !error && <p className="text-gray-600">No results found</p>
        )}
      </div>
    </div>
  );
}

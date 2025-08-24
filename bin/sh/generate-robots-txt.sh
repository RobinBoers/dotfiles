curl -X POST https://api.darkvisitors.com/robots-txts \
-H "Authorization: Bearer 75f000b5-029d-4c24-bf1a-45562337793b" \
-H "Content-Type: application/json" \
-d '{
    "agent_types": [
        "AI Assistant",
        "AI Data Scraper",
        "AI Search Crawler",
        "Undocumented AI Agent"
    ],
    "disallow": "/"
}' \
-o $1

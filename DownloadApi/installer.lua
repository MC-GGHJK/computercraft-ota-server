-- Configuration
local GITHUB_USER = "MC-GGHJK"
local GITHUB_REPO = "computercraft-ota-server"
local BRANCH = "main"
local BASE_URL = "https://raw.githubusercontent.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/" .. BRANCH .. "/"
local MANIFEST_FILE = "content.json"

-- Helper function to read a file
local function readFile(path)
    if not fs.exists(path) then return nil end
    local file = fs.open(path, "r")
    local content = file.readAll()
    file.close()
    return content
end

-- Helper function to save a file
local function saveFile(path, content)
    local dir = fs.getDir(path)
    if not fs.exists(dir) and dir ~= "" then
        fs.makeDir(dir)
    end
    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

-- Function to download a file from URL
local function downloadUrl(url)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        return content
    end
    return nil
end

-- Main update logic
local function update()
    print("Checking for updates...")

    -- 1. Download the new manifest
    local manifestUrl = BASE_URL .. MANIFEST_FILE
    print("Fetching manifest from: " .. manifestUrl)
    local newManifestJson = downloadUrl(manifestUrl)

    if not newManifestJson then
        print("Error: Could not download content.json")
        return
    end

    local newManifest = textutils.unserializeJSON(newManifestJson)
    if not newManifest then
        print("Error: Failed to parse new manifest JSON")
        return
    end

    -- 2. Load the old manifest (if exists)
    local oldManifest = {}
    local oldManifestJson = readFile(MANIFEST_FILE)
    if oldManifestJson then
        oldManifest = textutils.unserializeJSON(oldManifestJson) or {}
    end

    -- Create a lookup table for old file hashes for faster access
    local oldFileHashes = {}
    for _, item in ipairs(oldManifest) do
        if item.path and item.sha256 then
            oldFileHashes[item.path] = item.sha256
        end
    end

    -- 3. Compare and download
    local updatesCount = 0
    local totalFiles = #newManifest

    print("Found " .. totalFiles .. " files in remote manifest.")

    for _, item in ipairs(newManifest) do
        local path = item.path
        local url = item.url
        local newHash = item.sha256
        local oldHash = oldFileHashes[path]

        -- Check if file needs update
        if newHash ~= oldHash or not fs.exists(path) then
            print("Updating: " .. path)
            local fileContent = downloadUrl(url)

            if fileContent then
                saveFile(path, fileContent)
                updatesCount = updatesCount + 1
            else
                print("Failed to download: " .. path)
            end
        else
            -- File is up to date
            -- print("Skipping: " .. path .. " (Up to date)")
        end
    end

    -- 4. Save the new manifest locally
    saveFile(MANIFEST_FILE, newManifestJson)

    if updatesCount > 0 then
        print("Update complete! Updated " .. updatesCount .. " files.")
        print("Rebooting in 3 seconds...")
        sleep(3)
        os.reboot()
    else
        print("System is already up to date.")
    end
end

update()

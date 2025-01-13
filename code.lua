
-- Funktion, um alle registrierten Snippets zu erhalten
local function get_registered_snippets()
    local snippet_list = {}
    for name, _ in pairs(minetest.registered_snippets) do
        table.insert(snippet_list, name)
    end
    return snippet_list
end

-- Funktion, um ein Snippet zu löschen
local function delete_snippet(snippet_name)
    if minetest.registered_snippets[snippet_name] then
        minetest.registered_snippets[snippet_name] = nil
        return true
    end
    return false
end

-- Chat-Befehl registrieren, um alle Snippets im Chat auszugeben
minetest.register_chatcommand("lsc_snippets", {
    description = "list all snippets in chat.",
    privs = {server = true},
    func = function(name)
        local snippet_list = get_registered_snippets()
        local message = "Registered Snippets:\n" .. table.concat(snippet_list, "\n")
        minetest.chat_send_player(name, message)
        return true, "All registered snippets were listed."
    end,
})

-- Chat-Befehl registrieren, um alle Snippets in einem Formspec anzuzeigen
minetest.register_chatcommand("ls_snippets", {
    description = "List all regitered snippets in game.",
    privs = {server = true},
    func = function(name)
        local snippet_list = get_registered_snippets()
        local formspec = "size[6,8]" ..
                         "label[0,0;Registrierte Snippets:]" ..
                         "textlist[0,0.5;6,7;snippet_list;" .. table.concat(snippet_list, ",") .. "]" ..
                         "button_exit[2,7.5;2,1;exit;Schließen]"
        minetest.show_formspec(name, "snippet_list:snippets", formspec)
        return true, "Run successfuly."
    end,
})

-- Funktion, um Formspec-Eingaben zu verarbeiten
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "snippet_list:snippets" and fields.snippet_list then
        local event = minetest.explode_textlist_event(fields.snippet_list)
        if event.type == "DCL" then  -- Doppeltes Klicken zum Löschen
            local snippet_list = get_registered_snippets()
            local snippet_name = snippet_list[event.index]
            if delete_snippet(snippet_name) then
                minetest.chat_send_player(player:get_player_name(), "Snippet '" .. snippet_name .. "' wurde gelöscht.")
            else
                minetest.chat_send_player(player:get_player_name(), "Snippet '" .. snippet_name .. "' konnte nicht gelöscht werden.")
            end
            minetest.register_chatcommand("list_snippets_formspec", {
                description = "Liste alle registrierten Snippets in einem Formspec auf",
                privs = {server = true},
                func = function(name)
                    local snippet_list = get_registered_snippets()
                    local formspec = "size[6,8]" ..
                                     "label[0,0;Registrierte Snippets:]" ..
                                     "textlist[0,0.5;6,7;snippet_list;" .. table.concat(snippet_list, ",") .. "]" ..
                                     "button_exit[2,7.5;2,1;exit;Schließen]"
                    minetest.show_formspec(name, "snippet_list:snippets", formspec)
                    return true, "Alle registrierten Snippets wurden im Formspec aufgelistet."
                end,
            })
        end
    end
end)
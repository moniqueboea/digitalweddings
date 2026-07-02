<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Music Playlist | digitalweddings.love">
<cfset activePage = "music-playlist">
<cfset userId = session.user.id>

<cfparam name="form.action"        default="">
<cfparam name="url.saved"          default="">
<cfparam name="url.selftest"       default="">
<cfparam name="url.djsent"         default="">
<cfparam name="url.plsent"         default="">
<cfparam name="url.plself"         default="">
<cfparam name="url.error"          default="">

<!--- Ensure DJ columns exist (idempotent on first load) --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_name')
        ALTER TABLE dbo.WeddingSites ADD dj_name NVARCHAR(150) NULL
</cfquery>
<cfcatch></cfcatch>
</cftry>
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_contact_person')
        ALTER TABLE dbo.WeddingSites ADD dj_contact_person NVARCHAR(150) NULL
</cfquery>
<cfcatch></cfcatch>
</cftry>
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_email')
        ALTER TABLE dbo.WeddingSites ADD dj_email NVARCHAR(320) NULL
</cfquery>
<cfcatch></cfcatch>
</cftry>
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_phone')
        ALTER TABLE dbo.WeddingSites ADD dj_phone NVARCHAR(30) NULL
</cfquery>
<cfcatch></cfcatch>
</cftry>
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_website')
        ALTER TABLE dbo.WeddingSites ADD dj_website NVARCHAR(500) NULL
</cfquery>
<cfcatch></cfcatch>
</cftry>
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_notes')
        ALTER TABLE dbo.WeddingSites ADD dj_notes NVARCHAR(MAX) NULL
</cfquery>
<cfcatch></cfcatch>
</cftry>

<!--- Ensure playlist table exists --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF OBJECT_ID('dbo.PlaylistSongs','U') IS NULL
    CREATE TABLE dbo.PlaylistSongs (
        song_id       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id       BIGINT NOT NULL,
        playlist_type VARCHAR(20)   NOT NULL DEFAULT ('ceremony'),
        category      NVARCHAR(100) NOT NULL,
        sort_order    INT           NOT NULL DEFAULT (0),
        song_title    NVARCHAR(300) NOT NULL,
        artist        NVARCHAR(300) NULL,
        notes         NVARCHAR(MAX) NULL,
        music_link    NVARCHAR(500) NULL,
        created_at    DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at    DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PlaylistSongs_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
    )
</cfquery>
<cfcatch></cfcatch>
</cftry>

<!--- Load site --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date, slug, template,
           venue_name, venue_address, ceremony_start_time, reception_start_time,
           dj_name, dj_contact_person, dj_email, dj_phone, dj_website, dj_notes
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>

<!--- ============================================================
  SAVE DJ INFO
============================================================ --->
<cfif form.action EQ "save_dj" AND qSite.recordCount>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites
        SET dj_name           = <cfqueryparam value="#trim(form.dj_name)#"           cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dj_name))#">,
            dj_contact_person = <cfqueryparam value="#trim(form.dj_contact_person)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dj_contact_person))#">,
            dj_email          = <cfqueryparam value="#lCase(trim(form.dj_email))#"   cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dj_email))#">,
            dj_phone          = <cfqueryparam value="#trim(form.dj_phone)#"          cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dj_phone))#">,
            dj_website        = <cfqueryparam value="#trim(form.dj_website)#"        cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dj_website))#">,
            dj_notes          = <cfqueryparam value="#trim(form.dj_notes)#"          cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dj_notes))#">
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="music-playlist.cfm?saved=1" addToken="false">
</cfif>

<!--- ============================================================
  ADD SONG
============================================================ --->
<cfif form.action EQ "add_song" AND len(trim(form.song_title))>
    <cfquery name="qMaxSort" datasource="#application.config.datasource#">
        SELECT ISNULL(MAX(sort_order),0)+1 AS nextSort FROM dbo.PlaylistSongs
        WHERE user_id       = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
          AND playlist_type = <cfqueryparam value="#trim(form.playlist_type)#" cfsqltype="cf_sql_varchar">
          AND category      = <cfqueryparam value="#trim(form.category)#" cfsqltype="cf_sql_nvarchar">
    </cfquery>
    <cfquery datasource="#application.config.datasource#">
        INSERT INTO dbo.PlaylistSongs (user_id, playlist_type, category, sort_order, song_title, artist, notes, music_link)
        VALUES (
            <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
            <cfqueryparam value="#trim(form.playlist_type)#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#trim(form.category)#" cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#qMaxSort.nextSort#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#trim(form.song_title)#" cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#trim(form.artist)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.artist))#">,
            <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">,
            <cfqueryparam value="#trim(form.music_link)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.music_link))#">
        )
    </cfquery>
    <cflocation url="music-playlist.cfm?tab=#HTMLEditFormat(trim(form.playlist_type))#" addToken="false">
</cfif>

<!--- ============================================================
  EDIT SONG
============================================================ --->
<cfif form.action EQ "edit_song" AND isNumeric(form.song_id) AND len(trim(form.song_title))>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.PlaylistSongs
        SET song_title    = <cfqueryparam value="#trim(form.song_title)#" cfsqltype="cf_sql_nvarchar">,
            artist        = <cfqueryparam value="#trim(form.artist)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.artist))#">,
            category      = <cfqueryparam value="#trim(form.category)#" cfsqltype="cf_sql_nvarchar">,
            notes         = <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">,
            music_link    = <cfqueryparam value="#trim(form.music_link)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.music_link))#">,
            updated_at    = SYSUTCDATETIME()
        WHERE song_id = <cfqueryparam value="#val(form.song_id)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="music-playlist.cfm?tab=#HTMLEditFormat(trim(form.playlist_type))#" addToken="false">
</cfif>

<!--- ============================================================
  DELETE SONG
============================================================ --->
<cfif form.action EQ "delete_song" AND isNumeric(form.song_id)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.PlaylistSongs
        WHERE song_id = <cfqueryparam value="#val(form.song_id)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="music-playlist.cfm?tab=#HTMLEditFormat(trim(form.playlist_type))#" addToken="false">
</cfif>

<!--- ============================================================
  MOVE SONG (up/down)
============================================================ --->
<cfif form.action EQ "move_song" AND isNumeric(form.song_id) AND listFind("up,down", form.direction)>
    <cfquery name="qThisSong" datasource="#application.config.datasource#">
        SELECT song_id, sort_order, category, playlist_type FROM dbo.PlaylistSongs
        WHERE song_id = <cfqueryparam value="#val(form.song_id)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif qThisSong.recordCount>
        <cfif form.direction EQ "up">
            <cfquery name="qSwap" datasource="#application.config.datasource#">
                SELECT TOP 1 song_id, sort_order FROM dbo.PlaylistSongs
                WHERE user_id       = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                  AND playlist_type = <cfqueryparam value="#qThisSong.playlist_type#" cfsqltype="cf_sql_varchar">
                  AND category      = <cfqueryparam value="#qThisSong.category#" cfsqltype="cf_sql_nvarchar">
                  AND sort_order    < <cfqueryparam value="#qThisSong.sort_order#" cfsqltype="cf_sql_integer">
                ORDER BY sort_order DESC
            </cfquery>
        <cfelse>
            <cfquery name="qSwap" datasource="#application.config.datasource#">
                SELECT TOP 1 song_id, sort_order FROM dbo.PlaylistSongs
                WHERE user_id       = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                  AND playlist_type = <cfqueryparam value="#qThisSong.playlist_type#" cfsqltype="cf_sql_varchar">
                  AND category      = <cfqueryparam value="#qThisSong.category#" cfsqltype="cf_sql_nvarchar">
                  AND sort_order    > <cfqueryparam value="#qThisSong.sort_order#" cfsqltype="cf_sql_integer">
                ORDER BY sort_order ASC
            </cfquery>
        </cfif>
        <cfif qSwap.recordCount>
            <cfquery datasource="#application.config.datasource#">
                UPDATE dbo.PlaylistSongs SET sort_order = <cfqueryparam value="#qSwap.sort_order#" cfsqltype="cf_sql_integer">
                WHERE song_id = <cfqueryparam value="#qThisSong.song_id#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            </cfquery>
            <cfquery datasource="#application.config.datasource#">
                UPDATE dbo.PlaylistSongs SET sort_order = <cfqueryparam value="#qThisSong.sort_order#" cfsqltype="cf_sql_integer">
                WHERE song_id = <cfqueryparam value="#qSwap.song_id#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            </cfquery>
        </cfif>
    </cfif>
    <cflocation url="music-playlist.cfm?tab=#HTMLEditFormat(trim(form.playlist_type))#" addToken="false">
</cfif>

<!--- ============================================================
  SEND INITIAL DJ NOTIFICATION
============================================================ --->
<cfif (form.action EQ "send_dj_notify" OR form.action EQ "send_dj_notify_self") AND qSite.recordCount>
    <cfset isSelfTest = (form.action EQ "send_dj_notify_self")>
    <cfif NOT isSelfTest AND NOT len(trim(qSite.dj_email))>
        <cflocation url="music-playlist.cfm?error=noemail&tab=dj" addToken="false">
    </cfif>
    <cfset sendTo = isSelfTest ? session.user.email : trim(qSite.dj_email)>
    <cfset qSiteForEmail = qSite>
    <cfinclude template="email-theme-helper.cfm">
    <cfset djIsTest = isSelfTest>
    <cftry>
        <cfset djSubject = isSelfTest ? "[TEST] You've Been Selected as the DJ for an Upcoming Wedding" : "You've Been Selected as the DJ for an Upcoming Wedding">
        <cfmail to="#sendTo#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#djSubject#"
                type="html" timeout="60"><cfinclude template="email-dj-notify-body.cfm"></cfmail>
        <cfif isSelfTest>
            <cflocation url="music-playlist.cfm?selftest=1&tab=dj" addToken="false">
        <cfelse>
            <cflocation url="music-playlist.cfm?djsent=1&tab=dj" addToken="false">
        </cfif>
    <cfcatch>
        <cflocation url="music-playlist.cfm?error=sendfail&tab=dj" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- ============================================================
  SEND FULL PLAYLIST TO DJ (or self)
============================================================ --->
<cfif (form.action EQ "send_playlist" OR form.action EQ "send_playlist_self") AND qSite.recordCount>
    <cfset isPlSelf = (form.action EQ "send_playlist_self")>
    <cfif NOT isPlSelf AND NOT len(trim(qSite.dj_email))>
        <cflocation url="music-playlist.cfm?error=noemail&tab=dj" addToken="false">
    </cfif>
    <cfset sendTo = isPlSelf ? session.user.email : trim(qSite.dj_email)>
    <cfquery name="qCeremony" datasource="#application.config.datasource#">
        SELECT song_id, category, sort_order, song_title, artist, notes, music_link
        FROM dbo.PlaylistSongs
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
          AND playlist_type = 'ceremony'
        ORDER BY category, sort_order
    </cfquery>
    <cfquery name="qReception" datasource="#application.config.datasource#">
        SELECT song_id, category, sort_order, song_title, artist, notes, music_link
        FROM dbo.PlaylistSongs
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
          AND playlist_type = 'reception'
        ORDER BY category, sort_order
    </cfquery>
    <cfset qSiteForEmail = qSite>
    <cfinclude template="email-theme-helper.cfm">
    <cfset djIsTest = isPlSelf>
    <cftry>
        <cfset plSubject = isPlSelf ? "[TEST] Wedding Music Playlist - " : "Wedding Music Playlist - ">
        <cfset plSubject = plSubject & trim(qSite.couple_name_1) & " & " & trim(qSite.couple_name_2)>
        <cfmail to="#sendTo#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#plSubject#"
                type="html" timeout="60"><cfinclude template="email-dj-playlist-body.cfm"></cfmail>
        <cfif isPlSelf>
            <cflocation url="music-playlist.cfm?plself=1&tab=dj" addToken="false">
        <cfelse>
            <cflocation url="music-playlist.cfm?plsent=1&tab=dj" addToken="false">
        </cfif>
    <cfcatch>
        <cflocation url="music-playlist.cfm?error=plsendfail&tab=dj" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- ============================================================
  LOAD SONGS
============================================================ --->
<cfquery name="qAllSongs" datasource="#application.config.datasource#">
    SELECT song_id, playlist_type, category, sort_order, song_title, artist, notes, music_link
    FROM dbo.PlaylistSongs
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY playlist_type, category, sort_order
</cfquery>

<cfparam name="url.tab" default="ceremony">
<cfif NOT listFind("ceremony,reception,dj", url.tab)>
    <cfset url.tab = "ceremony">
</cfif>

<cfset ceremonyCats = ["Pre-Ceremony Music","Wedding Party Processional","Bride's Processional","Ceremony Moments","Recessional"]>
<cfset receptionCats = ["Cocktail Hour","Wedding Party Entrance","Couple's Grand Entrance","First Dance","Parent Dances","Dinner Music","Cake Cutting","Bouquet Toss","Garter Toss","Open Dance Floor","Last Dance","Do Not Play"]>

<cfinclude template="../includes/layout-start.cfm">
<style>
.pl-tab-bar { display:flex; gap:0; border-bottom:2px solid var(--border); margin-bottom:32px; }
.pl-tab { padding:12px 24px; font-size:14px; font-weight:600; color:var(--text-muted); cursor:pointer; border-bottom:3px solid transparent; margin-bottom:-2px; text-decoration:none; transition:color .15s; white-space:nowrap; }
.pl-tab:hover { color:var(--text); }
.pl-tab.active { color:var(--gold); border-bottom-color:var(--gold); }
.song-row { display:grid; grid-template-columns:1fr auto; align-items:start; gap:12px; padding:14px 0; border-bottom:1px solid var(--border); }
.song-row:last-child { border-bottom:0; }
.song-title { font-size:14px; font-weight:600; color:var(--text); margin-bottom:2px; }
.song-artist { font-size:13px; color:var(--text-muted); }
.song-meta { font-size:12px; color:var(--text-muted); margin-top:4px; }
.song-link { font-size:12px; color:var(--gold); text-decoration:none; }
.song-actions { display:flex; gap:4px; align-items:center; flex-shrink:0; }
.pl-cat-header { font-size:11px; font-weight:700; letter-spacing:3px; text-transform:uppercase; color:var(--text-muted); padding:18px 0 8px 0; border-top:1px solid var(--border); margin-top:8px; }
.pl-cat-header:first-of-type { border-top:0; margin-top:0; }
.cat-empty { font-size:13px; color:var(--text-muted); font-style:italic; padding:8px 0 12px 0; }
.add-song-form { background:var(--surface-alt,#faf9f7); border-radius:10px; padding:20px 24px; margin-top:24px; }
.dnp-section { background:#fff8f8; border:1px solid #fca5a5; border-radius:8px; padding:16px 20px; margin-top:8px; }
.dnp-section .pl-cat-header { color:#9b1c1c; border-color:#fca5a5; }
.btn-reorder { width:28px; height:28px; padding:0; display:flex; align-items:center; justify-content:center; font-size:14px; }
@media (max-width:640px) {
    .pl-tab { padding:10px 14px; font-size:13px; }
    .add-song-form .mfr { grid-template-columns:1fr !important; }
}
</style>

<section style="padding:60px 0">
<div class="container" style="max-width:900px">

    <div class="page-header" style="margin-bottom:32px">
        <p class="eyebrow">Planning Tools</p>
        <h1>Wedding Music <span class="script">Playlist</span></h1>
        <p style="color:var(--text-muted);font-size:15px;margin-top:8px;max-width:600px">Build your ceremony and reception playlists and share them with your DJ as a professional music worksheet.</p>
    </div>

    <!--- Flash messages --->
    <cfif url.saved EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">DJ contact information saved!</div>
    </cfif>
    <cfif url.djsent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Initial DJ notification sent to <cfoutput>#HTMLEditFormat(qSite.dj_email)#</cfoutput>!</div>
    </cfif>
    <cfif url.selftest EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Test DJ notification sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div>
    </cfif>
    <cfif url.plsent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Full playlist sent to your DJ at <cfoutput>#HTMLEditFormat(qSite.dj_email)#</cfoutput>!</div>
    </cfif>
    <cfif url.plself EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Test playlist sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div>
    </cfif>
    <cfif url.error EQ "noemail">
    <div class="alert alert-error" style="margin-bottom:24px">Please add your DJ&rsquo;s email address before sending. <a href="/members/music-playlist.cfm?tab=dj">Add DJ info &rarr;</a></div>
    </cfif>
    <cfif url.error EQ "sendfail" OR url.error EQ "plsendfail">
    <div class="alert alert-error" style="margin-bottom:24px">There was a problem sending the email. Please try again.</div>
    </cfif>

    <!--- Tab navigation --->
    <div class="pl-tab-bar">
        <a href="?tab=ceremony" class="pl-tab <cfif url.tab EQ 'ceremony'>active</cfif>">&#127929; Ceremony</a>
        <a href="?tab=reception" class="pl-tab <cfif url.tab EQ 'reception'>active</cfif>">&#127881; Reception</a>
        <a href="?tab=dj" class="pl-tab <cfif url.tab EQ 'dj'>active</cfif>">&#127918; DJ Info & Send</a>
    </div>

    <!--- ======================================================
      CEREMONY TAB
    ====================================================== --->
    <cfif url.tab EQ "ceremony">

    <cfquery name="qCeremonySongs" dbtype="query">
        SELECT * FROM qAllSongs WHERE playlist_type = 'ceremony' ORDER BY category, sort_order
    </cfquery>

    <!--- Category sections --->
    <cfset catDescriptions = {
        "Pre-Ceremony Music"      = "Music playing as guests are being seated before the ceremony begins.",
        "Wedding Party Processional" = "Music for the wedding party walking down the aisle.",
        "Bride's Processional"    = "The song played as the bride (or couple) walks down the aisle.",
        "Ceremony Moments"        = "Music for special moments: unity candle, prayer, communion, sand ceremony, etc.",
        "Recessional"             = "The exit song played after the ceremony is complete."
    }>

    <cfloop array="#ceremonyCats#" index="cat">
        <cfquery name="qCatRows" dbtype="query">
            SELECT * FROM qCeremonySongs WHERE category = '#cat#' ORDER BY sort_order
        </cfquery>

        <cfif cat EQ "Do Not Play">
        <div class="dnp-section">
        <cfelse>
        <div>
        </cfif>
            <div class="pl-cat-header"><cfoutput>#HTMLEditFormat(cat)#</cfoutput></div>
            <cfif structKeyExists(catDescriptions, cat)>
            <p style="font-size:13px;color:var(--text-muted);margin:0 0 8px 0"><cfoutput>#catDescriptions[cat]#</cfoutput></p>
            </cfif>

            <cfif qCatRows.recordCount>
                <cfoutput query="qCatRows">
                <div class="song-row">
                    <div>
                        <div class="song-title">#HTMLEditFormat(song_title)#</div>
                        <cfif len(trim(artist))><div class="song-artist">#HTMLEditFormat(artist)#</div></cfif>
                        <cfif len(trim(notes))><div class="song-meta">Notes: #HTMLEditFormat(notes)#</div></cfif>
                        <cfif len(trim(music_link))><div style="margin-top:4px"><a href="#HTMLEditFormat(music_link)#" target="_blank" rel="noopener noreferrer" class="song-link">&##9654; Listen</a></div></cfif>
                    </div>
                    <div class="song-actions">
                        <!--- Move up --->
                        <form method="post" action="/members/music-playlist.cfm" style="margin:0">
                            <input type="hidden" name="action" value="move_song">
                            <input type="hidden" name="song_id" value="#song_id#">
                            <input type="hidden" name="direction" value="up">
                            <input type="hidden" name="playlist_type" value="ceremony">
                            <button type="submit" class="btn btn-ghost btn-sm btn-reorder" title="Move up">&##8593;</button>
                        </form>
                        <!--- Move down --->
                        <form method="post" action="/members/music-playlist.cfm" style="margin:0">
                            <input type="hidden" name="action" value="move_song">
                            <input type="hidden" name="song_id" value="#song_id#">
                            <input type="hidden" name="direction" value="down">
                            <input type="hidden" name="playlist_type" value="ceremony">
                            <button type="submit" class="btn btn-ghost btn-sm btn-reorder" title="Move down">&##8595;</button>
                        </form>
                        <!--- Edit (toggle inline) --->
                        <button type="button" class="btn btn-ghost btn-sm" onclick="toggleEdit('edit-#song_id#')">Edit</button>
                        <!--- Delete --->
                        <form method="post" action="/members/music-playlist.cfm" style="margin:0">
                            <input type="hidden" name="action" value="delete_song">
                            <input type="hidden" name="song_id" value="#song_id#">
                            <input type="hidden" name="playlist_type" value="ceremony">
                            <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Remove this song?')">&times;</button>
                        </form>
                    </div>
                </div>
                <!--- Inline edit form (hidden) --->
                <div id="edit-#song_id#" style="display:none;background:var(--surface-alt,##faf9f7);border-radius:8px;padding:16px;margin-bottom:8px">
                    <form method="post" action="/members/music-playlist.cfm">
                        <input type="hidden" name="action" value="edit_song">
                        <input type="hidden" name="song_id" value="#song_id#">
                        <input type="hidden" name="playlist_type" value="ceremony">
                        <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Song Title *</label>
                                <input type="text" name="song_title" value="#HTMLEditFormat(song_title)#" required>
                            </div>
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Artist</label>
                                <input type="text" name="artist" value="#HTMLEditFormat(artist)#">
                            </div>
                        </div>
                        <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Category</label>
                                <select name="category">
                                    <cfloop array="#ceremonyCats#" index="copt">
                                    <option value="#HTMLEditFormat(copt)#" <cfif category EQ copt>selected</cfif>>#HTMLEditFormat(copt)#</option>
                                    </cfloop>
                                </select>
                            </div>
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Music Link</label>
                                <input type="url" name="music_link" value="#HTMLEditFormat(music_link)#" placeholder="YouTube, Spotify, Apple Music...">
                            </div>
                        </div>
                        <div class="field" style="margin-bottom:10px">
                            <label style="font-size:12px">Notes / Timing Instructions</label>
                            <input type="text" name="notes" value="#HTMLEditFormat(notes)#" placeholder="e.g. Start at 2:15">
                        </div>
                        <div style="display:flex;gap:8px">
                            <button type="submit" class="btn btn-primary btn-sm">Save</button>
                            <button type="button" class="btn btn-ghost btn-sm" onclick="toggleEdit('edit-#song_id#')">Cancel</button>
                        </div>
                    </form>
                </div>
                </cfoutput>
            <cfelse>
                <p class="cat-empty">No songs added yet.</p>
            </cfif>

            <!--- Add song form for this category --->
            <div class="add-song-form">
                <p style="font-size:12px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:var(--text-muted);margin-bottom:12px">Add Song</p>
                <form method="post" action="/members/music-playlist.cfm">
                    <input type="hidden" name="action" value="add_song">
                    <input type="hidden" name="playlist_type" value="ceremony">
                    <input type="hidden" name="category" value="<cfoutput>#HTMLEditFormat(cat)#</cfoutput>">
                    <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Song Title *</label>
                            <input type="text" name="song_title" placeholder="e.g. Canon in D" required>
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Artist</label>
                            <input type="text" name="artist" placeholder="e.g. Pachelbel">
                        </div>
                    </div>
                    <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Notes / Timing</label>
                            <input type="text" name="notes" placeholder="e.g. Start at 2:15, fade at end">
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Music Link</label>
                            <input type="url" name="music_link" placeholder="YouTube, Spotify, Apple Music...">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">+ Add to <cfoutput>#HTMLEditFormat(cat)#</cfoutput></button>
                </form>
            </div>
        </div>
        <cfif cat NEQ "Recessional"><div style="height:8px"></div></cfif>
    </cfloop>

    <div style="margin-top:28px;padding:20px 24px;background:var(--surface-alt,#faf9f7);border-radius:10px;border-left:4px solid var(--gold)">
        <p style="font-size:13px;color:var(--text-muted);margin:0">
            <strong>Tip:</strong> Use the up/down arrows to reorder songs within each category. Songs are sent to your DJ in this exact order.
        </p>
    </div>

    </cfif> <!--- end ceremony tab --->

    <!--- ======================================================
      RECEPTION TAB
    ====================================================== --->
    <cfif url.tab EQ "reception">

    <cfquery name="qReceptionSongs" dbtype="query">
        SELECT * FROM qAllSongs WHERE playlist_type = 'reception' ORDER BY category, sort_order
    </cfquery>

    <cfset rCatDescriptions = {
        "Cocktail Hour"          = "Background music as guests mingle after the ceremony.",
        "Wedding Party Entrance" = "Songs for each member of the wedding party to enter the reception.",
        "Couple's Grand Entrance"= "The big moment - the couple enters as newlyweds!",
        "First Dance"            = "The couple's first dance as newlyweds.",
        "Parent Dances"          = "Father-daughter dance, mother-son dance, or both parents.",
        "Dinner Music"           = "Background music during the dinner service.",
        "Cake Cutting"           = "Music for the cake cutting ceremony.",
        "Bouquet Toss"           = "Music for the bouquet toss.",
        "Garter Toss"            = "Music for the garter toss.",
        "Open Dance Floor"       = "Dance floor playlist - songs you want the DJ to play.",
        "Last Dance"             = "The final song of the night.",
        "Do Not Play"            = "Songs you absolutely do NOT want played at your wedding."
    }>

    <cfloop array="#receptionCats#" index="cat">
        <cfquery name="qRCatRows" dbtype="query">
            SELECT * FROM qReceptionSongs WHERE category = '#cat#' ORDER BY sort_order
        </cfquery>

        <cfif cat EQ "Do Not Play">
        <div class="dnp-section" style="margin-top:24px">
        <cfelse>
        <div>
        </cfif>
            <div class="pl-cat-header"><cfoutput>#HTMLEditFormat(cat)#</cfoutput><cfif cat EQ "Do Not Play"> &#9940;</cfif></div>
            <cfif structKeyExists(rCatDescriptions, cat)>
            <p style="font-size:13px;color:<cfif cat EQ 'Do Not Play'>##9b1c1c<cfelse>var(--text-muted)</cfif>;margin:0 0 8px 0"><cfoutput>#rCatDescriptions[cat]#</cfoutput></p>
            </cfif>

            <cfif qRCatRows.recordCount>
                <cfoutput query="qRCatRows">
                <div class="song-row">
                    <div>
                        <div class="song-title">#HTMLEditFormat(song_title)#</div>
                        <cfif len(trim(artist))><div class="song-artist">#HTMLEditFormat(artist)#</div></cfif>
                        <cfif len(trim(notes))><div class="song-meta">Notes: #HTMLEditFormat(notes)#</div></cfif>
                        <cfif len(trim(music_link))><div style="margin-top:4px"><a href="#HTMLEditFormat(music_link)#" target="_blank" rel="noopener noreferrer" class="song-link">&##9654; Listen</a></div></cfif>
                    </div>
                    <div class="song-actions">
                        <form method="post" action="/members/music-playlist.cfm" style="margin:0">
                            <input type="hidden" name="action" value="move_song">
                            <input type="hidden" name="song_id" value="#song_id#">
                            <input type="hidden" name="direction" value="up">
                            <input type="hidden" name="playlist_type" value="reception">
                            <button type="submit" class="btn btn-ghost btn-sm btn-reorder" title="Move up">&##8593;</button>
                        </form>
                        <form method="post" action="/members/music-playlist.cfm" style="margin:0">
                            <input type="hidden" name="action" value="move_song">
                            <input type="hidden" name="song_id" value="#song_id#">
                            <input type="hidden" name="direction" value="down">
                            <input type="hidden" name="playlist_type" value="reception">
                            <button type="submit" class="btn btn-ghost btn-sm btn-reorder" title="Move down">&##8595;</button>
                        </form>
                        <button type="button" class="btn btn-ghost btn-sm" onclick="toggleEdit('redit-#song_id#')">Edit</button>
                        <form method="post" action="/members/music-playlist.cfm" style="margin:0">
                            <input type="hidden" name="action" value="delete_song">
                            <input type="hidden" name="song_id" value="#song_id#">
                            <input type="hidden" name="playlist_type" value="reception">
                            <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Remove this song?')">&times;</button>
                        </form>
                    </div>
                </div>
                <div id="redit-#song_id#" style="display:none;background:var(--surface-alt,##faf9f7);border-radius:8px;padding:16px;margin-bottom:8px">
                    <form method="post" action="/members/music-playlist.cfm">
                        <input type="hidden" name="action" value="edit_song">
                        <input type="hidden" name="song_id" value="#song_id#">
                        <input type="hidden" name="playlist_type" value="reception">
                        <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Song Title *</label>
                                <input type="text" name="song_title" value="#HTMLEditFormat(song_title)#" required>
                            </div>
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Artist</label>
                                <input type="text" name="artist" value="#HTMLEditFormat(artist)#">
                            </div>
                        </div>
                        <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Category</label>
                                <select name="category">
                                    <cfloop array="#receptionCats#" index="ropt">
                                    <option value="#HTMLEditFormat(ropt)#" <cfif category EQ ropt>selected</cfif>>#HTMLEditFormat(ropt)#</option>
                                    </cfloop>
                                </select>
                            </div>
                            <div class="field" style="margin-bottom:0">
                                <label style="font-size:12px">Music Link</label>
                                <input type="url" name="music_link" value="#HTMLEditFormat(music_link)#" placeholder="YouTube, Spotify, Apple Music...">
                            </div>
                        </div>
                        <div class="field" style="margin-bottom:10px">
                            <label style="font-size:12px">Notes / DJ Instructions</label>
                            <input type="text" name="notes" value="#HTMLEditFormat(notes)#" placeholder="e.g. Mix into the next song">
                        </div>
                        <div style="display:flex;gap:8px">
                            <button type="submit" class="btn btn-primary btn-sm">Save</button>
                            <button type="button" class="btn btn-ghost btn-sm" onclick="toggleEdit('redit-#song_id#')">Cancel</button>
                        </div>
                    </form>
                </div>
                </cfoutput>
            <cfelse>
                <p class="cat-empty">No songs added yet.</p>
            </cfif>

            <div class="add-song-form <cfif cat EQ 'Do Not Play'>dnp-add</cfif>">
                <p style="font-size:12px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:<cfif cat EQ 'Do Not Play'>##9b1c1c<cfelse>var(--text-muted)</cfif>;margin-bottom:12px">Add <cfif cat EQ "Do Not Play">Song to Do Not Play<cfelse>Song</cfif></p>
                <form method="post" action="/members/music-playlist.cfm">
                    <input type="hidden" name="action" value="add_song">
                    <input type="hidden" name="playlist_type" value="reception">
                    <input type="hidden" name="category" value="<cfoutput>#HTMLEditFormat(cat)#</cfoutput>">
                    <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Song Title *</label>
                            <input type="text" name="song_title" placeholder="Song title" required>
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Artist</label>
                            <input type="text" name="artist" placeholder="Artist name">
                        </div>
                    </div>
                    <div class="mfr" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px"><cfif cat EQ "Do Not Play">Reason<cfelse>Notes / DJ Instructions</cfif></label>
                            <input type="text" name="notes" placeholder="<cfif cat EQ 'Do Not Play'>Optional reason<cfelse>Optional notes</cfif>">
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Music Link</label>
                            <input type="url" name="music_link" placeholder="YouTube, Spotify...">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">+ Add Song</button>
                </form>
            </div>
        </div>
        <div style="height:8px"></div>
    </cfloop>

    </cfif> <!--- end reception tab --->

    <!--- ======================================================
      DJ INFO & SEND TAB
    ====================================================== --->
    <cfif url.tab EQ "dj">

    <cfquery name="qSongCount" datasource="#application.config.datasource#">
        SELECT COUNT(*) AS total FROM dbo.PlaylistSongs
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:28px;align-items:start">
    <cfoutput>

        <!--- DJ Info form --->
        <div>
            <div class="panel">
                <p class="panel-title">DJ Contact Information</p>
                <form method="post" action="/members/music-playlist.cfm">
                    <input type="hidden" name="action" value="save_dj">
                    <div class="field">
                        <label>DJ / Company Name</label>
                        <input type="text" name="dj_name" maxlength="150"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.dj_name) : '')#"
                               placeholder="e.g. DJ John Smith or Sound Perfect DJ">
                    </div>
                    <div class="field">
                        <label>Contact Person</label>
                        <input type="text" name="dj_contact_person" maxlength="150"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.dj_contact_person) : '')#"
                               placeholder="Name of person to contact">
                    </div>
                    <div class="field">
                        <label>Email Address</label>
                        <input type="email" name="dj_email" maxlength="320"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.dj_email) : '')#"
                               placeholder="dj@example.com">
                    </div>
                    <div class="field">
                        <label>Phone Number</label>
                        <input type="tel" name="dj_phone" maxlength="30"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.dj_phone) : '')#"
                               placeholder="(555) 555-5555">
                    </div>
                    <div class="field">
                        <label>Website</label>
                        <input type="url" name="dj_website" maxlength="500"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.dj_website) : '')#"
                               placeholder="https://...">
                    </div>
                    <div class="field">
                        <label>Special DJ Notes</label>
                        <textarea name="dj_notes" rows="4" placeholder="Anything special your DJ should know...">#HTMLEditFormat(qSite.recordCount ? trim(qSite.dj_notes) : '')#</textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Save DJ Information</button>
                </form>
            </div>
        </div>

        <!--- Send panel --->
        <div>

            <!--- Initial notification --->
            <div class="panel" style="margin-bottom:20px">
                <p class="panel-title">Initial DJ Notification</p>
                <p style="color:var(--text-muted);font-size:14px;margin-bottom:16px;line-height:1.6">Let your DJ know they have been selected. This sends a friendly introduction email - not the full playlist.</p>

                <form method="post" action="/members/music-playlist.cfm" style="margin-bottom:10px">
                    <input type="hidden" name="action" value="send_dj_notify_self">
                    <button type="submit" class="btn btn-ghost" style="width:100%">&##128140; Send Test Email to Myself</button>
                </form>

                <cfif qSite.recordCount AND len(trim(qSite.dj_email))>
                <p style="font-size:12px;color:var(--text-muted);margin-bottom:12px">Will be sent to: <strong>#HTMLEditFormat(qSite.dj_email)#</strong></p>
                <form method="post" action="/members/music-playlist.cfm">
                    <input type="hidden" name="action" value="send_dj_notify">
                    <button type="submit" class="btn btn-secondary" style="width:100%">&##128231; Send Initial Email to DJ</button>
                </form>
                <cfelse>
                <div style="background:var(--light);border-radius:8px;padding:12px 14px;font-size:13px;color:var(--text-muted)">
                    &##128274; Add your DJ&rsquo;s email address to enable sending.
                </div>
                </cfif>
            </div>

            <!--- Full playlist --->
            <div class="panel">
                <p class="panel-title">Send Full Music Playlist</p>
                <p style="color:var(--text-muted);font-size:14px;margin-bottom:8px;line-height:1.6">Send the complete, professionally formatted music worksheet to your DJ.</p>
                <p style="font-size:13px;color:var(--text-muted);margin-bottom:16px">
                    <cfset cerCount = 0>
                    <cfset recCount = 0>
                    <cfloop query="qAllSongs">
                        <cfif playlist_type EQ "ceremony"><cfset cerCount++></cfif>
                        <cfif playlist_type EQ "reception"><cfset recCount++></cfif>
                    </cfloop>
                    Ceremony: <strong>#cerCount#</strong> songs &nbsp;&bull;&nbsp; Reception: <strong>#recCount#</strong> songs
                </p>

                <form method="post" action="/members/music-playlist.cfm" style="margin-bottom:10px">
                    <input type="hidden" name="action" value="send_playlist_self">
                    <button type="submit" class="btn btn-ghost" style="width:100%">&##128140; Send Test Playlist to Myself</button>
                </form>

                <cfif qSite.recordCount AND len(trim(qSite.dj_email))>
                <p style="font-size:12px;color:var(--text-muted);margin-bottom:12px">Will be sent to: <strong>#HTMLEditFormat(qSite.dj_email)#</strong></p>
                <form method="post" action="/members/music-playlist.cfm">
                    <input type="hidden" name="action" value="send_playlist">
                    <button type="submit" class="btn btn-primary" style="width:100%">&##127929; Send Playlist to DJ</button>
                </form>
                <cfelse>
                <div style="background:var(--light);border-radius:8px;padding:12px 14px;font-size:13px;color:var(--text-muted)">
                    &##128274; Add your DJ&rsquo;s email address to enable sending.
                </div>
                </cfif>
            </div>

        </div>

    </cfoutput>
    </div>

    </cfif> <!--- end dj tab --->

</div>
</section>

<script>
function toggleEdit(id) {
    var el = document.getElementById(id);
    el.style.display = el.style.display === 'none' ? 'block' : 'none';
}
</script>

<cfinclude template="../includes/layout-end.cfm">

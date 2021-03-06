-- Copyright 2016 gbrueckner.
--
-- This file is part of Snapp.
--
-- Snapp is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Snapp is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Snapp.  If not, see <http://www.gnu.org/licenses/>.


tell application "System Preferences"
    set securityPane to pane id "com.apple.preference.security"
    tell securityPane to reveal anchor "Privacy_Accessibility"
    launch
end tell
tell application "System Events"
    tell process "System Preferences"
        set visible to true
    end tell
end tell

#!/bin/bash

myPluginID=$(getNextPluginID)
myPlugin="plugin$myPluginID"
myPluginCommand="someday"
myPluginDescription="Shows $limitBy someday tasks ordered by '$orderBy'"
myPluginMethod="querySomeday"

eval "$myPlugin=('$myPluginCommand' '$myPluginDescription' '$myPluginMethod')"

querySomeday() {
  sqlite3 "$THINGSDB" "$(getSomedayQuery)"
}

getSomedayQuery() {
    read -rd '' query <<-SQL || true
SELECT
  CASE 
    WHEN AREA.title IS NOT NULL THEN AREA.title 
    WHEN PROJECT.title IS NOT NULL THEN PROJECT.title
    WHEN HEADING.title IS NOT NULL THEN HEADING.title
    ELSE "(No Context)"
  END,
TASK.title
FROM $TASKTABLE as TASK
LEFT OUTER JOIN $TASKTABLE PROJECT ON TASK.project = PROJECT.uuid
LEFT OUTER JOIN $AREATABLE AREA ON TASK.area = AREA.uuid
LEFT OUTER JOIN $TASKTABLE HEADING ON TASK.actionGroup = HEADING.uuid
WHERE TASK.$ISNOTTRASHED AND TASK.$ISTASK
AND TASK.$ISPOSTPONED AND TASK.$ISOPEN
ORDER BY TASK.$orderBy
LIMIT $limitBy
SQL
  echo "${query}"
}
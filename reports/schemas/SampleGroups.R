# vim: sw=4:ts=4:nu:nospell:fdc=4
#
#  Copyright 2013 Fred Hutchinson Cancer Research Center
#
#  Licensed under the Apache License, Version 2.0 (the 'License');
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an 'AS IS' BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

suppressMessages( library( flowWorkspace ) );
suppressMessages( library( RJSONIO ) );
suppressMessages( library( gdata ) );
suppressMessages( library( parallel ) );

wsPaths <- RJSONIO::fromJSON( labkey.url.params$wsPaths );

if ( length( wsPaths ) > 0 ){

    sampleGroups <- mclapply( wsPaths, function( wsPath ){
        suppressMessages( ws <- openWorkspace( wsPath, options = 1 ) );

        sampleGroupsTemp <- getSampleGroups(ws)[ , c(1,3) ];

        if ( length( as.character( unique( sampleGroupsTemp[[1]] ) ) ) > 1 ) {;
            sampleGroupsTemp <- sampleGroupsTemp[ sampleGroupsTemp$groupName != 'All Samples', ];

            sampleGroupsTemp$groupName <- drop.levels( sampleGroupsTemp$groupName );
        }

        sampleGroupsTemp <-
            cbind(
                sampleGroupsTemp,
                filename = sapply(
                    sampleGroupsTemp$sampleID,
                    function(x) flowWorkspace:::.getKeywordsBySampleID( ws, x, '$FIL' )
                )
            );
        sampleGroupsTemp <- sampleGroupsTemp[ , c(1,3) ];

        sampleGroupsTemp <- split( sampleGroupsTemp$filename, sampleGroupsTemp$groupName );

        return( sampleGroupsTemp );
    } );

    sampleGroupsList <- mclapply( sampleGroups, function( i ){
        mclapply( i, function( j ){
            length(j)
        })
    });

    names( sampleGroups ) <- wsPaths;
}

write( RJSONIO::toJSON( x = sampleGroupsList, asIs = T ), '${jsonout:outArray}' );
write( RJSONIO::toJSON( x = sampleGroups, asIs = T ), '${jsonout:outArray}' );


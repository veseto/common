    <?php 
        include("connection.php");
        //Deconde json
        $entityBody = file_get_contents('php://input');
        $decoded = json_decode($entityBody,true);

        //get json objects
        $circles = $decoded['circles'];    
        $ids=$decoded['indexes'];
        $deleted=$decoded['deleted'];
        //start return json creation
        $returnJson  = array('userid' => $decoded['userid']);
        $resDeleted  = array();

        $returnCircles = array();

        //Delete locally deleted circles
        for ($i = 0; $i < count($deleted); $i++) { 
            $delquery = "DELETE cd, f, h
                            FROM circle_definition cd
                            JOIN friend f 
                            JOIN history h 
                            ON f.circleName = cd.name AND f.circleOwner=cd.ownerId AND h.circleName=cd.name AND h.circleOwner=cd.ownerId
                            WHERE cd.ownerId='".$decoded['userid']."' AND cd.id='".$deleted[$i]."';";
            mysql_query($delquery);
            array_push($resDeleted, $deleted[$i]);
           
        }
        $returnJson['deleted'] = $resDeleted;

        //Insert newly created circles together with the friend list and history records
        for ($i = 0; $i < count($circles); ++$i) {
            $c = $circles[$i];
            
            //Insert new circles
            if ($c['lastRevision'] == 0) {
                $insertQuery = "INSERT INTO circle_definition (ownerId, name, numberOfFriends, lastRevision) VALUES ('".$c['ownerId']."', '".$c['name']."', '".$c['numberOfFriends']."' , '1')";
                mysql_query($insertQuery);
                $f = $circles[$i]['friends'];
                for ($j = 0; $j < count($f); $j++) {
                    $fr = $f[$j];
                    $insertFriendQuery = "INSERT INTO friend (circleName, friendName, friendIndexInCircle, balanceInCircle, circleOwner) VALUES ('".$fr['circleName']."', '".$fr['friendName']."', '".$fr['friendIndexInCircle']."', '0', '".$fr['circleOwner']."')";
                    mysql_query($insertFriendQuery);
                }
                $h = $circles[$i]['history'];
                for ($j = 0; $j < count($h); $j++) {
                    $hr = $h[$j];
                    $insertFriendQuery = "INSERT INTO history (circleName, circleOwner, sum, user, authorId, currency, revision) VALUES ('".$hr['circleName']."', '".$hr['circleOwner']."', '".$hr['sum']."', '".$hr['user']."', '".$hr['authorId']."', '".$hr['currency']."', '1')";
                    mysql_query($insertFriendQuery);

                    $updateQuery = "UPDATE friend SET balanceInCircle=balanceInCircle+".$hr['sum']." WHERE friendName ='".$hr['user']."' AND circleName='".$hr['circleName']."' AND circleOwner='".$hr['circleOwner']."'";
                    mysql_query($updateQuery);


                }
            } else {
                //insert history for old circles
                $selectQuery = "SELECT lastRevision FROM circle_definition WHERE ".$c['id'];
                $tmpRevision = mysql_fetch_assoc(mysql_query($selectQuery))['lastRevision'];
               // echo $selectQuery;
                $h = $circles[$i]['history'];
                $currentRevision = ++$tmpRevision;
                for ($j = 0; $j < count($h); $j++) {
                    $hr = $h[$j];
                    $insertFriendQuery = "INSERT INTO history (circleName, circleOwner, sum, user, authorId, currency, revision) VALUES ('".$hr['circleName']."', '".$hr['circleOwner']."', '".$hr['sum']."', '".$hr['user']."', '".$hr['authorId']."', '".$hr['currency']."', '".$currentRevision."')";
                    mysql_query($insertFriendQuery);
                    $updateQuery = "UPDATE friend SET balanceInCircle=balanceInCircle+".$hr['sum']." WHERE friendName ='".$hr['user']."' AND circleName='".$hr['circleName']."' AND circleOwner='".$hr['circleOwner']."'";
                    mysql_query($updateQuery);
                }
                $updateQuery = "UPDATE circle_definition SET lastRevision=".$currentRevision." WHERE id=".$circles[$i]['id'];
                mysql_query($updateQuery);

            }
            //add new circle ids to list
                $selectQuery2 = "SELECT id, lastRevision FROM circle_definition WHERE name='".$c['name']."' AND ownerId='".$c['ownerId']."'";
                $newCircles = mysql_fetch_array(mysql_query($selectQuery2));
                array_push($ids, array('id' => $newCircles['id'], 'lastRevision' => $c['lastRevision']));
            
          //  echo $selectQuery2;
        }


        //Update circle history with delta

        //TODO Change to userid in circle friends
        $selectQuery = "SELECT * FROM circle_definition WHERE ownerId='".$decoded['userid']."'";
        $res = mysql_query($selectQuery);
        while($tmpCirc = mysql_fetch_array($res)){
            $contains = FALSE;
            $higherRevision = FALSE;
            $indexesRevision = 0;
            for ($q=0; $q < count($ids); $q++) { 
                $tmpId = $ids[$q];
                if ($tmpId ['id']== $tmpCirc['id']) {
                    $contains = TRUE;
                    //echo $tmpId['lastRevision']." <-ids db-> ".$tmpCirc['lastRevision'];
                    if ($tmpId['lastRevision'] < $tmpCirc['lastRevision']) {
                        $indexesRevision = $tmpId['lastRevision'];
                        $higherRevision = TRUE;
                    }
                    break;
                }
            }

            if (($contains && $higherRevision) || !$contains){
                $tmpCirc['history'] = array();
//            echo $tmpCirc['id']."  contains: ".(int)$contains."  higherRevision: ".(int)$higherRevision;

                $friendsQuery = "SELECT * FROM friend WHERE circleName='".$tmpCirc['name']."' AND circleOwner='".$tmpCirc['ownerId']."'";
                $friendRes = mysql_query($friendsQuery);
                $friendArray = array();
                while($r = mysql_fetch_array($friendRes)){
                    array_push($friendArray, $r);
                }
                if ($higherRevision){
                    $newHistoryQuery = "SELECT * FROM history WHERE circleName='".$tmpCirc['name']."' AND circleOwner='".$tmpCirc['ownerId']."' AND revision > ".$indexesRevision;
                } else {
                    $newHistoryQuery = "SELECT * FROM history WHERE circleName='".$tmpCirc['name']."' AND circleOwner='".$tmpCirc['ownerId']."'";
                }
                $newHistory = mysql_query($newHistoryQuery);
                while ($hRow = mysql_fetch_array($newHistory)) {
                    array_push($tmpCirc['history'], $hRow);   
                }
            
                $tmpCirc['friends'] = $friendArray;
                array_push($returnCircles, $tmpCirc);
            }
                

        }
        
        
        $returnJson['circles'] = $returnCircles;
        echo json_encode(array('data' => $returnJson));

    ?>              
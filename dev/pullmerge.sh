#!/bin/bash

param1="$1"


# Configuration des versions
START=14
END=23

if [ -z "$param1" ]; then
    echo "Usage: $0 <pull|merge|all>"
    echo
    echo "Example:"
    echo "$0 pull   # For pull only"
    echo "$0 merge  # For merge only"
    echo "$0 all    # For pull then merge"
    echo
    exit 1
fi

if [ "x$param1" = "xall" ] || [ "x$param1" = "xpull" ]; then
	echo "--- STEP Pull : Update directories (git pull) ---"

	for (( i=$START; i<=$END; i++ ))
	do
	    DIR="dolibarr_$i.0"

	    if [ -d "$DIR" ]; then
	        echo ">> Mise à jour de $DIR..."
	        cd "$DIR" || exit

	        # We want to be sure we are on good brnahc and we pull
	        git checkout "$i.0" && git pull

	        if [ $? -ne 0 ]; then
	            echo "ERREUR : The pull on $DIR has failed. We stop here."
	            exit 1
	        fi

	        cd ..
	    else
	        echo "Warning : The directory $DIR does not exists, switch to next one."
	    fi
	done
fi


if [ "x$param1" = "xall" ] || [ "x$param1" = "xmerge" ]; then
	echo -e "\n--- STEP Merge : Cascade of Merges (xx-1 -> xx) ---"

	for (( i=$((START+1)); i<=$END; i++ ))
	do
	    PREV=$((i-1))
	    CURRENT=$i
	    DIR_CURRENT="dolibarr_$CURRENT.0"
	    DIR_PREV="dolibarr_$PREV.0"

	    if [ -d "$DIR_CURRENT" ] && [ -d "$DIR_PREV" ]; then
	        echo ">> Fusion de dolibarr_$PREV vers dolibarr_$CURRENT..."

	        echo "   - Go on dir $DIR_CURRENT"
	        cd "$DIR_CURRENT" || exit

	        # Add previous directory to a local remote for the merge
	        # This allow to merge without the need of a common remote repository, which may not be the case here as we have only local clones.
	        REMOTE_NAME="local_prev"
	        git remote remove $REMOTE_NAME 2>/dev/null
	        git remote add $REMOTE_NAME "../$DIR_PREV"
	        git fetch $REMOTE_NAME

	        # Try to merge
	        git merge "$REMOTE_NAME/$PREV.0" -m "Automated merge from $PREV.0 by tool pullmerge.sh"

	        if [ $? -eq 0 ]; then
	            echo "Success on merge. Try to push..."
	            git push

	            if [ $? -ne 0 ]; then
	                echo "ERREUR : The push of $DIR_CURRENT has failed. We stop here."
	                exit 1
	            fi
	        else
	            echo "ERREUR : Conflict or error on merge into $DIR_CURRENT. We stop here."
	            # Optionnel : git merge --abort pour laisser le repo propre
	            exit 1
	        fi

	        # Nettoyage du remote temporaire
	        git remote remove $REMOTE_NAME
	        cd ..
	    fi
	done
fi

echo -e "\nSuccess !"

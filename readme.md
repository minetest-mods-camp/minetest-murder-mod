# Minetest Murder


### How do I play it?

The goal of the cop is to kill the murderer, the goal of the murderer to kill everyone, while as the victims, they simply have to survive. The cop has a gun to shoot the killer with, a sprint serum, and a radar to check if the killer is nearby; if the cop kills a victim, they are both eliminated. The killer has 2 gadgets: a knife and a finder chip. You can discover what they do by reading their descriptions. The victim has the radar and the sprint serum.
  
### How do I configure it?

1) Creating the arena using
`/murderadmin create <arena name> [min players] [max players]`
where min players is equal to the minimun amount of players to make the arena start, and max players to the maximum amount of players that an arena can have.

2) Editing the arena using
`/murderadmin edit <arena name>`
in this menu you can add spawn points and set up the sign to enter the arena: the spawn points are where the players will spawn when they enter the arena, while the sign is just the way to enter it (by clicking it).

3) Setting the match duration in seconds using
`/murderadmin matchduration <arena name> <duration in seconds>`

4) Enabling the arena using
`/murderadmin enable <arena name>`

<br/>

Once you've done this you can click the sign and start playing :) <br/>
Use `/help murderadmin` to see al the commands.

<br/><br/>

### Translations <br/><hr/>
You can translate the mod in your language by creating a file in the locale folder like this: `murder.LANGUAGE.tr`
and pasting in it the translation template that is in the file `template.txt` (beware **spaces matter**).

<br/>

### Dependencies <hr/>
* [arena_lib](https://gitlab.com/zughy-friends-minetest/arena_lib/) by Zughy and friends

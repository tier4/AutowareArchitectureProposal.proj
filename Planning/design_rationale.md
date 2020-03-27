# Planning Architecture Rationale

Driving in public roads involves many different functionalities including: 
- Calculates route that navigates to desired goal
- Plans maneuver to follow the route (e.g. when to lane change, when to turn at intersection)
- Make sure that vehicle does not collide with obstacles, including pedestrians and other vehicles)
- Make sure that the vehicle follows traffic rules during the navigation. This includes following traffic light, stopping at stoplines, stopping at crosswalks, etc. 

## Considered Architecture

Before designing planning architecture, we have looked into papers including ones from the teams participated to DARPA Urban Challenge. We have also investigated the planning architecture of Apollo-Auto(version 5.5).

Summary is illustrated below.

### Boss:
The planner is decomposed to three layers: mission, behavior, and motion. Mission calculates the high level global path from starting point to goal point, behavior makes tactical decision such as lane change decisions and manuevers at intersection, and motion calculates low level trajectory with consideration of kinematic model of the vehicle.

**pros**
* It is intuitive as data flow is one-directional from mission to behavior to motion.
* It is suitable for OSS used world-wide since all traffic rule handling is done in behavior layer, and developers only need to modify behavior layer to support their local rules.
  
**cons** 
* Behavior layer can only make "conservative" decisions. Since the behavior layer has no way of knowing the actual trajectory that is calculated by following motion layer, behavior layer cannot be certain about validity of decisions. For example, behavior planner can command lane change only when it is obvious that there is no obstacle in the target lane, and it is not possible to do "aggressive" lane change as an architecture.

### CMU Dr. paper
The paper addresses the demerit of splitting behavior layer and motion layer, and proposes an algorithm to handle decision making and trajectory optimization simultaneously.

**pros** 
* It can make more "aggressive" decisions compared to BOSS type architecture.

**Cons**
* The paper focuses on lane change, but real environment involves more different kinds of decision making, such as traffic lights and crosswalks. It is questionable that we can handle different kinds of traffic rules with one optimization algorithm.
* Also, since decision making is also target of optimization, it is usually difficult to add user specific constraints to decision making.

### Victor Tango Type
Victor Tango type splits Behavior and Motion layer like Boss type. However, unlike BOSS type, there is a feedback from motion wether decision made by behaviro layer is achievable or not.
**Pros**
* It overcomes the weaknes of Boss type and is able to consider trajectory at behavior level
* Behavior and Motion is still separated so it can be easily localized to country specific traffic rules.

**Cons**
* The interface between behavior and motion would be tight and dense. It has risk of having heavy inter-dependency, making it difficult to replace one of the modules with new algorithms in the future.

### Apollo
Apollo kept updating planning module at each version update. In version 5.5, they have taken different approach from others. Apollo split the behavior planner into scenarios, such as intersection, parking, and lane following. In each scenario module, it calls decider and optmizer libraries to achieve specific scenarios

**Pros**
* Specific parameter tunings is available for different scenarios, making it relatively easier to add new traffic rules for different countries
* Different optimizers can be used for different purpose

**Cons** 
* As the number of scenario increases, planning selector(or scenario selector) may get very complex. 

## Autoware Planning Architecture
Considering prons and cons of different approach, we have came to conclusion to take hybrid approach of Apollo and Boss type approach. 

We broke planning modules into scenarios just like Apollo, but into more high level scenario, such as OnRoad and Parking. Apollo has smaller units of scenario, such as intersection and traffic lights, but we have come to conclusion that those scenarios may occur in parallel(e.g. intsection with traffic lights and crosswalks) and preparing combined-scenario modules would make scenario-selector too complex to be maintained. Instead we made scenario to be more broad concept in order to keep the number of scenarios to be lower to keep scenario selector comprehensible. Currently we only have OnRoad and Parking, and we might possibly have HighWay and InEmergency in the future. 

More investigation is required to clearly set the definition of “Scenario” module, but convention is that new scenario must only be added whenever different "paradigm" for planning is needed. 

For example, currently we have OnRoad and Parking modules. OnRoad is used to drive along public roads, whereas Parking is used for driving free space, and it would be difficult to develop an algorithm to support requirements for both scenarios. OnRoad wouldn't require complex path planner as shape of lanes are already given from Map stack, but it must be done at higher frequency to drive at higher speed, whereas parking requires considreation of cut-backs in free space with lower constraint about computation time. Therefore, it would make more sense to split them into different scenarios. 

Note that we didn't split OnRoad into smaller scenarios unlike Apollo. We have considered all traffic rule related scenes on public roads, including yielding, traffic lights, crosswalks, and bare intersections, to be essentially velocity planner along lane and can be handled within single scheme. (explained in [Bahavior_velocity_planner.md](/Planning/On_road/Behavior/Bahavior_velocity_planner.md))
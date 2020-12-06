/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:meta/meta.dart';

final _rowHeight = 100.0;
final _borderRadius = BorderRadius.circular(_rowHeight / 2);

//A BountyTile to display a bounty on the bounty board
class BountyTile extends StatelessWidget {
  final Bounty bounty;
  //final ValueChanged<Bounty> onTap;
  final IconData iconLocation;
  //final Color color;

  const BountyTile({
    Key key,
    @required this.bounty,
    //@required this.color,
    @required this.iconLocation,
    //this.onTap,
  })  : assert(bounty != null),
        //assert(color != null),
        assert(iconLocation != null),
        super(key: key);


//TODO: add _navigateToBounty(BuildContext context)
  @override
  Widget buildTile(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Container(
            height: _rowHeight,
            child: InkWell(
                borderRadius: _borderRadius,
                highlightColor: Colors.green[100],
                splashColor: Colors.green[200],
                //onTap: () => _navigateToBounty(context),
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            iconLocation,
                            size: 60.0,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Bounty: ' + bounty.bountyid,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline,
                          ),
                        ),
                      ],
                    )))));
  }
}
*/
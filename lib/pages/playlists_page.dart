import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/new_playlist_widget.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class CardList extends StatelessWidget {
  
  const CardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Consumer<PlaylistsModel>(
            builder: (context, playlists, child) {
              return ListView.builder(
                itemCount: playlists.items.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (playlists.items[index].latestPlayed) {
                      return Container();
                  }
                  if (playlists.items[index].favourites) {
                    return Wrap(
                      children: [
                        ListTile(
                          title: Text(playlists.items[index].name),
                          visualDensity: VisualDensity(vertical: 0),
                          leading: BrowsableImage(backgroundColor: Colors.red, icon: Icons.favorite),
                          subtitle: Text('${playlists.items[index].firstPageSongs.totalElements} songs'),
                            onTap: () => NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {'playlist': playlists.items[index].copy(code: '', url: '/favourites')})
                        ),
                        Divider(),
                      ],
                    );
                  }
                  return ListTile(
                          leading: BrowsableImage(),
                          visualDensity: VisualDensity(vertical: 0),
                          title: Text(playlists.items[index].name),
                          subtitle: Text('${playlists.items[index].firstPageSongs.totalElements} songs'),
                          onTap: () => NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {'playlist': playlists.items[index].copy(url : '/${playlists.items[index].code}')})
                  );
                },
              );
            }        
            )
        ],
      ),
    );
  }
}

class _PlaylistsPageState extends State<PlaylistsPage> {

  PanelController pc = PanelController();

  @override
  void initState() {
    super.initState();
    ApiService.getPlaylistsForCurrentUser().then((v){
      Provider.of<PlaylistsModel>(context, listen: false).addAll(v);
    });
  }

  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      body: SlidingUpPanel(backdropEnabled: true, 
                           body: createPlaylist(), 
                           controller: pc, 
                           panel: NewPlaylistWidget(panelController : pc),
                           borderRadius: radius,
                           maxHeight: MediaQuery.of(context).size.height - 300,
                           minHeight: 0
      ),
      floatingActionButton: Visibility(visible: true, child:FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          onPressed: () {
            pc.isPanelOpen ? pc.close() : pc.open();
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
      )),
    );
  }

  Widget createPlaylist() {
    return CardList();
  }
}
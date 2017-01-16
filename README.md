# docker-ffmpeg-qsv

```sh
git clone https://github.com/pocka/docker-ffmpeg-qsv
cd docker-ffmpeg-qsv
cp /path/to/MediaServerStudio*.tar.gz ./
make

docker run -v /data:/data pocka/ffmpeg-qsv -i /data/foo.ts -c:v h264_qsv -look_ahead 0 -q 20 /data/foo.mp4
```

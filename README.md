<h1>Automatic1111 Stable Diffusion web UI</h1>

[![RunPod](https://api.runpod.io/badge/runpod-workers/worker-a1111)](https://www.runpod.io/console/hub/runpod-workers/worker-a1111)

- Runs [Automatic1111 Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) and exposes its `txt2img` API endpoint
- Comes pre-packaged with the [**Deliberate v6**](https://huggingface.co/XpucT/Deliberate) model

---

## Usage

The `input` object accepts any valid parameter for the Automatic1111 `/sdapi/v1/txt2img` endpoint. Refer to the [Automatic1111 API Documentation](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/API) for a full list of available parameters (like `seed`, `sampler_name`, `batch_size`, `styles`, `override_settings`, etc.).

### Example Request

Here's an example payload to generate an image:

```json
{
  "input": {
    "prompt": "a photograph of an astronaut riding a horse",
    "negative_prompt": "text, watermark, blurry, low quality",
    "steps": 25,
    "cfg_scale": 7,
    "width": 512,
    "height": 512,
    "sampler_name": "DPM++ 2M Karras"
  }
}
```

```shell
curl -H "Authorization: Bearer ea752a8d247748a3db45cf86d8f4684c" \
"https://civitai.com/api/download/models/1891887"
```

```shell
wget -q -O /mimimeter_2.safetensors "https://civitai-delivery-worker-prod.5ac0637cfd0766c97916cefa3764fbdf.r2.cloudflarestorage.com/model/139142/mimimeter.uQ5g.safetensors?X-Amz-Expires=86400&response-content-disposition=attachment%3B%20filename%3D%22mimimeter.safetensors%22&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=e01358d793ad6966166af8b3064953ad/20250627/us-east-1/s3/aws4_request&X-Amz-Date=20250627T115344Z&X-Amz-SignedHeaders=host&X-Amz-Signature=3dca8b3855056e163bfd244411738f999d82fc513197d203c659d7c47383fbaa"
```
```shell
curl -s -L -H "Authorization: Bearer ea752a8d247748a3db45cf86d8f4684c" "https://civitai.com/api/download/models/1891887"
```

```shell
docker build --platform linux/amd64 --tag misterfil/worker-a1111 .

docker build --platform linux/amd64 --tag misterfil/worker-a1111:latest --build-arg CIVITAI_TOKEN=ea752a8d247748a3db45cf86d8f4684c .

docker push misterfil/worker-a1111:latest

docker run -it misterfil/worker-a1111:latest
docker run --gpus all -it misterfil/worker-a1111:latest
docker run --gpus all -p 3000:3000 -it misterfil/worker-a1111:latest

```

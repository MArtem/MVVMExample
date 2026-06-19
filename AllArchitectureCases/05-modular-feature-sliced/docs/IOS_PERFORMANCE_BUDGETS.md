# iOS Performance Budgets

## Purpose
Defines measurable performance expectations for production iOS work.

## Default Budgets
Adjust per product/device class when real targets exist.

### Launch
- Cold launch: no unnecessary synchronous network/database/media work before first usable screen.
- Warm launch: restore visible local content quickly; defer refresh.

### Scrolling
- Repeated rows use `ScrollView -> LazyVStack/List -> ForEach -> RowView` or an equivalent virtualized pattern.
- No sync media/file/database/network work in row render paths.
- Scroll callbacks update semantic state only, not every pixel.
- Use Instruments when users report hitching or when feed/list work changes.

### Main Thread
- No known >250ms main-thread hangs in primary flows.
- Heavy parsing, decoding, thumbnail generation, compression, hashing, and DB preparation run off-main.

### Memory
- Media caches are bounded.
- Full-resolution media is not retained across many rows.
- Repeated navigation/scrolling must not show unbounded growth.

### Rendering
- Heavy shadows/materials/blur/masks/clips in repeated rows require review/profiling.
- Avoid broad implicit animations on large containers.

## Required Performance Report
State:
1. Scenario tested.
2. Device/simulator.
3. Tool used.
4. Metrics observed.
5. Remaining risk if profiling was not possible.
